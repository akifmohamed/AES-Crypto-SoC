// mbist_ctrl.v — Memory BIST controller running the March C- algorithm
// on a 256x8 SRAM (address width 8, data width 8).
//
// March C- (11n) — the standard 11-step march:
//   Step 1:  up    W0
//   Step 2:  up    R0, W1
//   Step 3:  up    R1, W0
//   Step 4:  down  R0, W1
//   Step 5:  down  R1, W0
//   Step 6:  down  R0
// (Wx = write x, Rx = read-and-check x)
//
// Ports:
//   go        : start a BIST run (pulse)
//   done      : high when BIST finished
//   pass      : high if no fault found
//   fail      : high if a fault was detected (sticky until reset)
//   fault_addr: address of first fault (for debug)
`timescale 1ns/1ps

module mbist_ctrl #(
    parameter AW = 8,
    parameter DW = 8
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        go,
    // memory interface (connected to wrapper's MBIST port)
    output reg         m_we,
    output reg  [AW-1:0] m_addr,
    output reg  [DW-1:0] m_din,
    input  wire [DW-1:0] m_dout,
    // results
    output reg         done,
    output reg         pass,
    output reg         fail,
    output reg  [AW-1:0] fault_addr
);
    localparam S_IDLE = 0, S_W0 = 1, S_R0W1 = 2, S_R1W0 = 3,
               S_D_R0W1 = 4, S_D_R1W0 = 5, S_D_R0 = 6, S_DONE = 7;

    reg [2:0]  state;
    reg [AW-1:0] addr;
    reg        up;              // direction: 1=up (0..max), 0=down (max..0)
    reg [DW-1:0] exp;           // expected data
    reg        phase;           // 0 = first op of step, 1 = second op of step
    integer    i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= S_IDLE;
            addr       <= 0;
            up         <= 1;
            exp        <= 0;
            phase      <= 0;
            m_we       <= 0;
            m_addr     <= 0;
            m_din      <= 0;
            done       <= 0;
            pass       <= 0;
            fail       <= 0;
            fault_addr <= 0;
        end else begin
            // defaults
            m_we <= 0;
            case (state)
                S_IDLE: begin
                    done <= 0; pass <= 0; fail <= 0;
                    if (go) begin
                        state <= S_W0;
                        addr  <= 0;
                        up    <= 1;
                    end
                end
                // ---- Step 1: up W0 ----
                S_W0: begin
                    m_we   <= 1;
                    m_addr <= addr;
                    m_din  <= 0;
                    if (up) begin
                        if (addr == {AW{1'b1}}) begin state <= S_R0W1; addr <= 0; up <= 1; phase <= 0; end
                        else addr <= addr + 1;
                    end
                end
                // ---- Step 2: up R0, W1 ----
                S_R0W1: begin
                    if (!phase) begin
                        // read and check 0
                        m_we   <= 0;
                        m_addr <= addr;
                        if (m_dout != 0) begin fail_state(addr); end
                        phase  <= 1;
                    end else begin
                        // write 1
                        m_we   <= 1;
                        m_addr <= addr;
                        m_din  <= {DW{1'b1}};
                        phase  <= 0;
                        if (addr == {AW{1'b1}}) begin state <= S_R1W0; addr <= 0; up <= 1; phase <= 0; end
                        else addr <= addr + 1;
                    end
                end
                // ---- Step 3: up R1, W0 ----
                S_R1W0: begin
                    if (!phase) begin
                        m_we   <= 0;
                        m_addr <= addr;
                        if (m_dout != {DW{1'b1}}) begin fail_state(addr); end
                        phase  <= 1;
                    end else begin
                        m_we   <= 1;
                        m_addr <= addr;
                        m_din  <= 0;
                        phase  <= 0;
                        if (addr == {AW{1'b1}}) begin state <= S_D_R0W1; addr <= {AW{1'b1}}; up <= 0; phase <= 0; end
                        else addr <= addr + 1;
                    end
                end
                // ---- Step 4: down R0, W1 ----
                S_D_R0W1: begin
                    if (!phase) begin
                        m_we   <= 0;
                        m_addr <= addr;
                        if (m_dout != 0) begin fail_state(addr); end
                        phase  <= 1;
                    end else begin
                        m_we   <= 1;
                        m_addr <= addr;
                        m_din  <= {DW{1'b1}};
                        phase  <= 0;
                        if (addr == 0) begin state <= S_D_R1W0; addr <= {AW{1'b1}}; up <= 0; phase <= 0; end
                        else addr <= addr - 1;
                    end
                end
                // ---- Step 5: down R1, W0 ----
                S_D_R1W0: begin
                    if (!phase) begin
                        m_we   <= 0;
                        m_addr <= addr;
                        if (m_dout != {DW{1'b1}}) begin fail_state(addr); end
                        phase  <= 1;
                    end else begin
                        m_we   <= 1;
                        m_addr <= addr;
                        m_din  <= 0;
                        phase  <= 0;
                        if (addr == 0) begin state <= S_D_R0; addr <= {AW{1'b1}}; up <= 0; phase <= 0; end
                        else addr <= addr - 1;
                    end
                end
                // ---- Step 6: down R0 ----
                S_D_R0: begin
                    m_we   <= 0;
                    m_addr <= addr;
                    if (m_dout != 0) begin fail_state(addr); end
                    if (addr == 0) begin
                        state <= S_DONE;
                        done  <= 1;
                        pass  <= 1;
                    end else addr <= addr - 1;
                end
                S_DONE: begin
                    // hold done/pass; go again to re-run
                    if (go) begin state <= S_IDLE; end
                end
                default: state <= S_IDLE;
            endcase
        end
    end

    // helper: record fault and jump to DONE
    task fail_state(input [AW-1:0] a);
        begin
            fail       <= 1;
            fault_addr <= a;
            state      <= S_DONE;
            done       <= 1;
        end
    endtask

endmodule
