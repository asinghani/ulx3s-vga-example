`default_nettype none

module top (
    output logic [7:0] led,
    input logic [6:0] btn,
    input logic clk_25mhz,

    output logic gn14, gn15, gn16, gn17,
    output logic gp16, gp17,
    output logic gn21, gn22, gn23, gn24,
    output logic gp21, gp22, gp23, gp24,
    
    output logic ftdi_rxd,
    input logic ftdi_txd
);

    logic [2:0] red, green, blue;
    logic hsync, vsync;

    // Pinout of the VGA PMOD
    // We check 'valid' here to avoid outputting outside of the 640x480 pixel area
    // IMPORTANT: Make sure to do this on your own chip as well, otherwise some
    // VGA monitors will not accept the signal
    assign {gn21, gn22, gn23, gn24} = valid ? {red[2:0], 1'b0} : '0;
    assign {gp21, gp22, gp23, gp24} = valid ? {blue[2:0], 1'b0} : '0;
    assign {gn14, gn15, gn16, gn17} = valid ? {green[2:0], 1'b0} : '0;
    assign gp16 = vsync;
    assign gp17 = hsync;

    // h_idx = column, v_idx = row
    logic [9:0] v_idx, h_idx;
    logic valid;

    vga vga (
        .v_idx, .h_idx, .valid,
        .vsync, .hsync,
        .rst(~btn[0]), .clk(clk_25mhz)
    );

    // Generate the test pattern
    // This may look familiar from 18240
    // TODO: replace this with your own graphics code
    always_comb begin
        if (v_idx > 240) begin
            red = '0;
            green = '0;
            blue = '0;
        end
        else begin
            red = ((h_idx >= 320) && (h_idx < 640));

            green = ((h_idx >= 160) && (h_idx < 320)) ||
                    ((h_idx >= 480) && (h_idx < 640));

            blue = ((h_idx >= 80) && (h_idx < 160))  ||
                   ((h_idx >= 240) && (h_idx < 320)) ||
                   ((h_idx >= 400) && (h_idx < 480)) ||
                   ((h_idx >= 560) && (h_idx < 640));
        end
    end

endmodule

module vga (
    output logic [9:0] v_idx,
    output logic [9:0] h_idx,
    output logic valid,
    output logic vsync, hsync,

    input logic rst,
    input logic clk
);

assign valid = (v_idx < 480) && (h_idx < 640);

always @(posedge clk) begin
    if (rst) begin
        v_idx <= 0;
        h_idx <= 0;

        vsync <= 1;
        hsync <= 1;
    end
    else begin
        hsync <= 1;
        h_idx <= h_idx + 1;

        // Horizontal sync region
        if (h_idx >= 656 && h_idx < 752) begin
            hsync <= 1'b0;
        end

        // End of row
        if (h_idx >= 800) begin
            h_idx <= 0;
            v_idx <= v_idx + 1;

            // Vertical sync region
            if (v_idx >= 490 && v_idx < 492) begin
                vsync <= 0;
            end
            else begin
                vsync <= 1;
            end

            // End of frame
            if (v_idx >= 525) begin
                v_idx <= 0;
            end
        end
    end
end

endmodule
