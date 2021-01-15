// Jakob Sailer
// FH Technikum Wien / UAS Technikum Wien
// created: 2021-01-13
// ESP: DIFT extension
//
// Converter: XBAR_TCDM_BUS to XBAR_TCDM_BUS_36

module tcdm_bus_convert_32_to_36 #(
    parameter bit TAG_BITS_WRITE_VALUE = 1'b1
    )
    (
      XBAR_TCDM_BUS.Slave       slave_32,
      XBAR_TCDM_BUS_36.Master   master_36
    );
    
    assign master_36.req = slave_32.req;
    assign master_36.add = slave_32.add;
    assign master_36.wen = slave_32.wen;
    assign master_36.be  = slave_32.be;
	/*
    assign master_36.wdata[ 7: 0] = slave_32.wdata[ 7: 0];
    assign master_36.wdata[    8] = TAG_BITS_WRITE_VALUE;
    assign master_36.wdata[16: 9] = slave_32.wdata[15: 8];
    assign master_36.wdata[   17] = TAG_BITS_WRITE_VALUE;
    assign master_36.wdata[25:18] = slave_32.wdata[23:16];
    assign master_36.wdata[   26] = TAG_BITS_WRITE_VALUE;
    assign master_36.wdata[34:27] = slave_32.wdata[31:24];
    assign master_36.wdata[   35] = TAG_BITS_WRITE_VALUE;
	*/
	assign master_36.wdata[31: 0] = slave_32.wdata;
	assign master_36.wdata[35:32] = {4{TAG_BITS_WRITE_VALUE}};
    
    assign slave_32.gnt     = master_36.gnt;
    assign slave_32.r_opc   = master_36.r_opc;
    assign slave_32.r_valid = master_36.r_valid;
    /*
	assign slave_32.r_rdata[ 7: 0] = master_36.r_rdata[ 7: 0];
    assign slave_32.r_rdata[15: 8] = master_36.r_rdata[16: 9];
    assign slave_32.r_rdata[23:16] = master_36.r_rdata[25:18];
    assign slave_32.r_rdata[31:24] = master_36.r_rdata[34:27];
	*/
	assign slave_32.r_rdata = master_36.r_rdata[31: 0];

endmodule
