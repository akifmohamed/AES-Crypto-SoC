// mbist_ctrl.v — March C- BIST controller (VERIFIED in simulation)
// Read pipeline: sub=0 addr out -> sub=1 wait -> sub=2 wait -> sub=3 check+write
// (2 registers in read path: RAM dout + rd_data => need 2 wait cycles)
// March C-: up W0, up R0W1, up R1W0, down R0W1, down R1W0, down R0
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
    reg [2:0]  step;        // 0..5
    reg        down;
    reg [AW-1:0] addr;
    reg [1:0]  sub;         // 0=addr, 1=wait, 2=wait, 3=check
    reg [DW-1:0] rd_data;
    reg        running;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            step <= 0; down <= 0; addr <= 0; sub <= 0;
            rd_data <= 0; running <= 0;
            m_we <= 0; m_addr <= 0; m_din <= 0;
            done <= 0; pass <= 0; fail <= 0; fault_addr <= 0;
        end else begin
            m_we <= 0;
            rd_data <= m_dout;
            if (!running) begin
                if (go) begin
                    running <= 1; done <= 0; pass <= 0; fail <= 0;
                    step <= 0; down <= 0; addr <= 0; sub <= 0;
                end
            end else begin
                case (step)
                    0: begin // up W0
                        m_we <= 1; m_addr <= addr; m_din <= 0;
                        if (addr == {AW{1'b1}}) begin step <= 1; addr <= 0; end
                        else addr <= addr + 1;
                    end
                    1,2,3,4: begin // R<exp> W<val>
                        case (sub)
                            0: begin m_we <= 0; m_addr <= addr; sub <= 1; end
                            1: begin sub <= 2; end
                            2: begin sub <= 3; end
                            3: begin
                                if (step == 1 || step == 3) begin // expect 0, write FF
                                    if (rd_data != {DW{1'b0}}) begin fail_state(addr); end
                                    m_din <= {DW{1'b1}};
                                end else begin // expect FF, write 0
                                    if (rd_data != {DW{1'b1}}) begin fail_state(addr); end
                                    m_din <= {DW{1'b0}};
                                end
                                m_we <= 1; m_addr <= addr;
                                sub <= 0;
                                if (!down) begin
                                    if (addr == {AW{1'b1}}) begin
                                        if (step == 2) begin step <= 3; down <= 1; addr <= {AW{1'b1}}; end
                                        else begin step <= step + 1; addr <= 0; end
                                    end else addr <= addr + 1;
                                end else begin
                                    if (addr == {AW{1'b0}}) begin
                                        if (step == 4) begin step <= 5; addr <= {AW{1'b1}}; end
                                        else begin step <= step + 1; addr <= {AW{1'b1}}; end
                                    end else addr <= addr - 1;
                                end
                            end
                        endcase
                    end
                    5: begin // down R0
                        case (sub)
                            0: begin m_we <= 0; m_addr <= addr; sub <= 1; end
                            1: begin sub <= 2; end
                            2: begin sub <= 3; end
                            3: begin
                                if (rd_data != {DW{1'b0}}) begin fail_state(addr); end
                                sub <= 0;
                                if (addr == {AW{1'b0}}) begin done <= 1; pass <= 1; running <= 0; end
                                else addr <= addr - 1;
                            end
                        endcase
                    end
                endcase
            end
        end
    end

    task fail_state(input [AW-1:0] a);
        begin
            fail <= 1; fault_addr <= a; done <= 1; running <= 0;
        end
    endtask

endmodule
