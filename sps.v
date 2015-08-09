module SPS(input clk, in,in2,ps2_clk,ps2_data, output [6:0] segments, segments2,output reg buzzer , output reg [6:0]  f,u,l1,l2 );
	wire [7:0] max;
	reg [3:0] max1;
	keyboard(max,clk,ps2_clk,ps2_data);
	reg state=0;
	wire [3:0] count1;
	wire [3:0] count;
	wire [3:0] diff;
	//assign buzzer = (diff>=max);
	second1 g1 (clk,in2,count1); 
	second1 g2 (clk,in,count);
	assign diff = count1 - count;
	seven_segment_decoder1 s1(diff,segments); 
	seven_segment_decoder1 s2(max1,segments2); 
	
	always@(posedge clk)
		begin
		case(max)
		8'h45:begin max1<=4'b0000; end
		8'h16:begin max1<=4'b0001; end
		8'h1E:begin max1<=4'b0010; end
	   8'h26:begin max1<=4'b0011; end	
		8'h25:begin max1<=4'b0100; end
		8'h2E:begin max1<=4'b0101; end
		8'h36:begin max1<=4'b0110; end
		8'h3D:begin max1<=4'b0111; end
		8'h3E:begin max1<=4'b1000; end
		8'h46:begin max1<=4'b1001; end
		default:begin max1 <=4'b0010 ; end
		endcase
		if(diff>=max1)
		begin
		buzzer=1;
		f=~(7'b1110001);
		u=~(7'b0111110);
		l1=~(7'b0111000);
		l2=~(7'b0111000);
		//buzzer = (diff>=max1);
		end
else begin 
buzzer=0;	
      f=(7'b1111111);
		u=(7'b1111111);
		l1=(7'b1111111);
		l2=(7'b1111111);
		end
end	
endmodule

module second1 (input clk, in,output reg[3:0] count); 
	reg state=0;

	always @ (posedge clk) 
		begin
			case (state) 
				0: if(~in) begin state<=1;end 
				1: if(in) begin state<=0; 
					case(count) 
						4'b0000: begin count <= 4'b0001; end 
						4'b0001: begin count <= 4'b0010; end 
						4'b0010: begin count <= 4'b0011; end 
						4'b0011: begin count <= 4'b0100; end 
						4'b0100: begin count <= 4'b0101; end 
						4'b0101: begin count <= 4'b0110; end
						4'b0110: begin count <= 4'b0111; end
						4'b0111: begin count <= 4'b1000; end
						4'b1000: begin count <= 4'b1001; end
						4'b1001: begin count <= 4'b0000; end
						default: begin count <= 4'b0000; end 
					endcase
				end 
			endcase 
		end
		
		
endmodule

module seven_segment_decoder1(num,segments); 
	input[3:0] num; 
	output [6:0] segments;
	reg [6:0] segments; 
	always@(num) 
		begin 
			case (num) 
				0: segments <= ~7'b0111111; 
				1: segments <= ~7'b0000110; 
				2: segments <= ~7'b1011011; 
				3: segments <= ~7'b1001111; 
				4: segments <= ~7'b1100110; 
				5: segments <= ~7'b1101101; 
				6: segments <= ~7'b1111101; 
				7: segments <= ~7'b0000111; 
				8: segments <= ~7'b1111111; 
				9: segments <= ~7'b1101111; 
				default: segments <= 7'b0000000; 
			endcase 
		end 
endmodule 

module keyboard (output reg [7:0] char,input clk,input ps2_clk,input ps2_data);


parameter idle    = 2'b01;
parameter receive = 2'b10;
parameter ready   = 2'b11;


reg [1:0]  state=idle;
reg [15:0] rxtimeout=16'b0000000000000000;
reg [10:0] rxregister=11'b11111111111;
reg [1:0]  datasr=2'b11;
reg [1:0]  clksr=2'b11;
reg [7:0]  rxdata;


reg datafetched;
reg rxactive;
reg dataready;


always @(posedge clk ) 
begin 
  if(datafetched==1 && rxdata != 8'b1111_0000 && rxdata != 8'b1110_0000)
    char <=rxdata;
end  
  
always @(posedge clk ) 
begin 
  rxtimeout<=rxtimeout+1;
  datasr <= {datasr[0],ps2_data};
  clksr  <= {clksr[0],ps2_clk};


  if(clksr==2'b10)
    rxregister<= {datasr[1],rxregister[10:1]};


  case (state) 
    idle: 
    begin
      rxregister <=11'b11111111111;
      rxactive   <=0;
      dataready  <=0;
      rxtimeout  <=16'b0000000000000000;
      if(datasr[1]==0 && clksr[1]==1)
      begin
        state<=receive;
        rxactive<=1;
      end   
    end
    
    receive:
    begin
      if(rxtimeout==50000)
        state<=idle;
      else if(rxregister[0]==0)
      begin
        dataready<=1;
        rxdata<=rxregister[8:1];
        state<=ready;
        datafetched<=1;
      end
    end
    
    ready: 
    begin
      if(datafetched==1)
      begin
        state     <=idle;
        dataready <=0;
        rxactive  <=0;
      end  
    end  
  endcase
end 
endmodule
