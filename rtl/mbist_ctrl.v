// mbist_ctrl.v — March C- BIST controller for 256x8 SRAM (v2: sync-RAM-safe)
`timescale 1ns/1ps

module mbist_ctrl #(
    parameter AW = 8,
    parameter DW = 8
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        go,
    output reg         m_we,
    output reg  [AW-1:0] m_addr,
    output reg  [DW-1:0] m_din,
    input  wire [DW-1:0] m_dout,
    output reg         done,
    output reg         pass,
    output reg         fail,
    output reg  [AW-1:0] fault_addr
);
    localparam S_IDLE = 0, S_W0 = 1, S_R0W1 = 2, S_R1W0 = 3,
               S_D_R0W1 = 4, S_D_R1W0 = 5, S_D_R0 = 6, S_DONE = 7;

    reg [2:0]  state;
    reg [AW-1:0] addr;
    reg        up;
    reg        phase;
    reg [DW-1:0] rd_data;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= S_IDLE; addr <= 0; up <= 1; phase <= 0;
            rd_data <= 0;
            m_we <= 0; m_addr <= 0; m_din <= 0;
            done <= 0; pass <= 0; fail <= 0; fault_addr <= 0;
        end else begin
            m_we <= 0;
            rd_data <= m_dout;
            case (state)
                S_IDLE: begin
                    done <= 0; pass <= 0; fail <= 0;
                    if (go) begin state <= S_W0; addr <= 0; up <= 1; end
                end
                S_W0: begin
                    m_we <= 1; m_addr <= addr; m_din <= 0;
                    if (addr == {AW{1'b1}}) begin state <= S_R0W1; addr <= 0; up <= 1; phase <= 0; end
                    else addr <= addr + 1;
                end
                S_R0W1: begin
                    if (!phase) begin
                        m_we <= 0; m_addr <= addr;
                        phase <= 1;
                    end else begin
                        if (rd_data != 0) begin fail_state(addr); end
                        m_we <= 1; m_addr <= addr; m_din <= {DW{1'b1}};
                        phase <= 0;
                        if (addr == {AW{1'b1}}) begin state <= S_R1W0; addr <= 0; up <= 1; phase <= 0; end
                        else addr <= addr + 1;
                    end
                end
                S_R1W0: begin
                    if (!phase) begin
                        m_we <= 0; m_addr <= addr;
                        phase <= 1;
                    end else begin
                        if (rd_data != {DW{1'b1}}) begin fail_state(addr); end
                        m_we <= 1; m_addr <= addr; m_din <= 0;
                        phase <= 0;
                        if (addr == {AW{1'b1}}) begin state <= S_D_R0W1; addr <= {AW{1'b1}}; up <= 0; phase <= 0; end
                        else addr <= addr + 1;
                    end
                end
                S_D_R0W1: begin
                    if (!phase) begin
                        m_we <= 0; m_addr <= addr;
                        phase <= 1;
                    end else begin
                        if (rd_data != 0) begin fail_state(addr); end
                        m_we <= 1; m_addr <= addr; m_din <= {DW{1'b1}};
                        phase <= 0;
                        if (addr == 0) begin state <= S_D_R1W0; addr <= {AW{1'b1}}; up <= 0; phase <= 0; end
                        else addr <= addr - 1;
                    end
                end
                S_D_R1W0: begin
                    if (!phase) begin
                        m_we <= 0; m_addr <= addr;
                        phase <= 1;
                    end else begin
                        if (rd_data != {DW{1'b1}}) begin fail_state(addr); end
                        m_we <= 1; m_addr <= addr; m_din <= 0;
                        phase <= 0;
                        if (addr == 0) begin state <= S_D_R0; addr <= {AW{1'b1}}; up <= 0; phase <= 0; end
                        else addr <= addr - 1;
                    end
                end
                S_D_R0: begin
                    if (!phase) begin
                        m_we <= 0; m_addr <= addr;
                        phase <= 1;
                    end else begin
                        if (rd_data != 0) begin fail_state(addr); end
                        phase <= 0;
                        if (addr == 0) begin state <= S_DONE; done <= 1; pass <= 1; end
                        else addr <= addr - 1;
                    end
                end
                S_DONE: begin if (go) state <= S_IDLE; end
                default: state <= S_IDLE;
            endcase
        end
    end

    task fail_state(input [AW-1:0] a);
        begin
            fail <= 1; fault_addr <= a; state <= S_DONE; done <= 1;
        end
    endtask

endmodule
