`timescale 1ns / 1ps

module uartprog #(
    parameter FILENAME=""
)(
    input clk,
    input mprj_ready,
    output reg r_Rx_Serial  // used by task UART_WRITE_BYTE
);

reg r_Clock = 0;
parameter c_BIT_PERIOD = 8681; // used by task UART_WRITE_BYTE
parameter c_CLOCK_PERIOD_NS = 100;

//reg [7:0] mem [31:0];
reg [7:0] INSTR [16384-1:0];
integer instr_count = 0;
reg ready;
reg test;
integer count;
integer uart_counter;
reg [7:0] data;
integer tx_count;
integer state_count;
parameter [1:0] IDLE = 2'b00, START_TX = 2'b01, DATA_TX = 2'b10, STOP_TX = 2'b11;
reg [1:0] state, next_state;
reg valid;

always @ ( posedge r_Clock ) begin
  if (mprj_ready) begin
    ready = 1'b1;
  end else begin
    ready = 1'b0;
  end
end

initial begin
        test = 1'b1;
       // #1000 test = 1'b1;
end

always @(posedge clk) begin
	count = count + 1;
	end
	
always @(count) begin	
	if(count > 1740) begin 
	  	r_Clock = ~r_Clock;
		count = 0;
	end
end

always @(posedge clk or negedge clk) begin
	if(next_state == IDLE) begin
   	 state_count = 32'd0;
  	end
  	else begin
  	state_count = state_count + 32'd1;
  	end
 end

initial begin
   $readmemh(FILENAME,INSTR);
end

// State Machine
always @(posedge clk) begin
	if(~ready) begin
	state = IDLE;
	end
	else begin
	state = next_state;
	end
end

always @(posedge clk) begin
	case(state)
	IDLE	 : begin
		  // $display("In IDLE State");
		   r_Rx_Serial <= 1'b1;
		   next_state = (~valid && (state_count == 32'd00)) ? IDLE : START_TX;
		   end
	START_TX : begin
		  // $display("Sending Start Bit");
		   r_Rx_Serial <= 1'b0;
		   next_state = (state_count == 32'd696) ? DATA_TX : START_TX;
		   state_count = (state_count == 32'd696) ? 32'd0 : state_count;
       	   end
        DATA_TX : begin
        	  // $display("Sending Data Bit");
        	   r_Rx_Serial <= data[tx_count];
        	   tx_count = (state_count == 32'd696) ? (tx_count + 32'd1) : tx_count;
        	   next_state = (tx_count == 32'd8) ? STOP_TX : DATA_TX;
        	   state_count = (state_count == 32'd696) ? 32'd0 : state_count;
        	   end
        STOP_TX : begin
        	  // $display("Sending End Bit");
		   r_Rx_Serial <= 1'b1;
		   next_state = (state_count == 32'd696) ? IDLE : STOP_TX;
		   state_count = (state_count == 32'd696) ? 32'd0 : state_count;
 		   tx_count = 32'd0;
		   valid = 1'b0;//(state_count == 32'd20) ? 1'b0 : valid;
       	   end
       endcase
end		   
		   
		   
/*task UART_WRITE_BYTE;
    //input r_Clock;
    input [7:0] i_Data;
    integer     ii;
    //integer tx_count = 32'd0;
    begin
   	// @ (posedge r_Clock);
   	// r_Rx_Serial = 1'b0;
    	//always @(posedge r_Clock) begin
    		if(tx_count == 32'd0) begin
        		// Send Start Bit
        		$display("Sending start bit");
        		r_Rx_Serial = 1'b0;
        		#(c_BIT_PERIOD);
       		#1000;
       	end
      // end		//tx_count = tx_count + 32'd1;
      		//end
      	//end/
      		//else if(tx_count == 32'd1) begin
      		/*	// Send Stop Bit
        		$display("Sending end bit");
        		r_Rx_Serial = 1'b1;
        		#(c_BIT_PERIOD);
        	end
      		
		//else begin
        	// Send Data Byte
       	 for (ii=0; ii<8; ii=ii+1) begin
             	$display("Sending data bit");
            	r_Rx_Serial = i_Data[ii];
            	$display("Data bit, %h, %h",ii,i_Data[ii]);
            	#(c_BIT_PERIOD);
        	end

        	// Send Stop Bit
        	$display("Sending end bit");
        	r_Rx_Serial = 1'b1;
        	#(c_BIT_PERIOD);
        	//end
     end
endtask // UART_WRITE_BYTE
*/



always @(posedge r_Clock)  begin
	if(~ready && test) begin
		valid = 1'b0;
		uart_counter = 32'd0;
		data = 8'h00;
    		//r_Rx_Serial <= 1'b1;
    		//$display("Starting");
    	end
    	else if(ready && test) begin
    		if((instr_count < 16384) && ({INSTR[instr_count],INSTR[instr_count+1],INSTR[instr_count+2],INSTR[instr_count+3]} != 32'h00000FFF)) begin
    			if(uart_counter == 32'd0) begin
    				data = INSTR[instr_count];
    				uart_counter = uart_counter + 32'd1;
    				valid = 1;
    			end
    			else if(uart_counter == 32'd1) begin
    				data = INSTR[instr_count+1];
    				uart_counter = uart_counter + 32'd1;
    				valid = 1;
    			end
    			else if(uart_counter == 32'd2) begin
    				data = INSTR[instr_count+2];
    				uart_counter = uart_counter + 32'd1;
    				valid = 1;
    			end
    			else if(uart_counter == 32'd3) begin
    				data = INSTR[instr_count+3];
    				uart_counter = 32'd0;
    				instr_count = instr_count + 32'd4;
    				valid = 1;
    				//$display("Instruction Count ,%d",instr_count);
    			end
    		end
    		else begin
    			if(uart_counter == 32'd0) begin
    				data = 8'h00;
    				uart_counter = uart_counter + 32'd1;
    				valid = 1;
    			end
    			else if(uart_counter == 32'd1) begin
    				data = 8'h00;
    				uart_counter = uart_counter + 32'd1;
    				valid = 1;
    			end
    			else if(uart_counter == 32'd2) begin
    				data = 8'h0F;
    				uart_counter = uart_counter + 32'd1;
    				valid = 1;
    			end
    			else if(uart_counter == 32'd3) begin
    				data = 8'hFF;
    				uart_counter = uart_counter + 32'd1;
    				valid = 1;
    			end
    			else if(uart_counter == 32'd4) begin
    				valid = 0;
    			end
    		end    		
 end
end

    	
    /*while (~mprj_ready && test) begin
     $display("2nd Step");
      #(c_CLOCK_PERIOD_NS);
      //@(posedge r_Clock); 
      r_Rx_Serial = 1'b1;
      $display("3rd Step");
    end*/
    /*while (instr_count<255 && INSTR[instr_count]!=32'h00000FFF) begin
      	//@(posedge r_Clock);
       #100;
       //UART_WRITE_BYTE(INSTR[instr_count][31:24]);
       // @(posedge r_Clock);
       #100;
       // UART_WRITE_BYTE(INSTR[instr_count][23:16]);
       // @(posedge r_Clock);
       #100;
       // UART_WRITE_BYTE(INSTR[instr_count][15:8]);
       // @(posedge r_Clock);
       #100;
        UART_WRITE_BYTE(INSTR[instr_count][7:0]);
       // @(posedge r_Clock);
       #100;
        instr_count = instr_count + 1'b1;
    end*/
    /*#(c_CLOCK_PERIOD_NS);
   // @(posedge r_Clock);
    UART_WRITE_BYTE(8'h00);
    #(c_CLOCK_PERIOD_NS);
   // @(posedge r_Clock);
    UART_WRITE_BYTE(8'h00);
    #(c_CLOCK_PERIOD_NS);
   // @(posedge r_Clock);
    UART_WRITE_BYTE(8'h0F);
    #(c_CLOCK_PERIOD_NS);
   // @(posedge r_Clock);
    UART_WRITE_BYTE(8'hFF);
    #(c_CLOCK_PERIOD_NS);
   // @(posedge r_Clock);
   $display("UART END");*/


endmodule

