// Jakob Sailer
// FH Technikum Wien / UAS Technikum Wien
// created: 2021-01-13
// ESP: DIFT extension
//
// Converter: XBAR_TCDM_BUS_36 to XBAR_TCDM_BUS

module tcdm_bus_convert_36_to_32 #(
    parameter bit TAG_BITS_READ_VALUE = 1'b1
    )
    (
      XBAR_TCDM_BUS_36.Slave    slave_36,
      XBAR_TCDM_BUS.Master      master_32
    );
    
    assign master_32.req = slave_36.req;
    assign master_32.add = slave_36.add;
    assign master_32.wen = slave_36.wen;
    assign master_32.be  = slave_36.be;
    assign master_32.wdata[ 7: 0] = slave_36.wdata[ 7: 0];
    assign master_32.wdata[15: 8] = slave_36.wdata[16: 9];
    assign master_32.wdata[23:16] = slave_36.wdata[25:18];
    assign master_32.wdata[31:24] = slave_36.wdata[34:27];
    
    assign slave_36.gnt     = master_32.gnt;
    assign slave_36.r_opc   = master_32.r_opc;
    assign slave_36.r_valid = master_32.r_valid;
    assign slave_36.r_data[ 7: 0] = master_32.r_data[ 7: 0];
    assign slave_36.r_data[    8] = TAG_BITS_READ_VALUE;
    assign slave_36.r_data[16: 9] = master_32.r_data[15: 8];
    assign slave_36.r_data[   17] = TAG_BITS_READ_VALUE;
    assign slave_36.r_data[25:18] = master_32.r_data[23:16];
    assign slave_36.r_data[   26] = TAG_BITS_READ_VALUE;
    assign slave_36.r_data[34:27] = master_32.r_data[31:24];
    assign slave_36.r_data[   35] = TAG_BITS_READ_VALUE;

endmodule
