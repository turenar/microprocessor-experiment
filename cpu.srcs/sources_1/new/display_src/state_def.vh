//for oled_ctrl.v
`define Octrl_idle    2'b00
`define Octrl_init    2'b01
`define Octrl_exam    2'b10
`define Octrl_done    2'b11

//for spi_ctrl.v
`define spi_idle     3'b001
`define spi_send     3'b010
`define spi_hold1    3'b011
`define spi_hold2    3'b100
`define spi_hold3    3'b101
`define spi_hold4    3'b110
`define spi_done     3'b111

//for delay_gen.v
`define Delay_idle     2'b01
`define Delay_hold     2'b10
`define Delay_done     2'b11

//for oled_init.v
`define Transition1     5'd1
`define Transition2     5'd2
`define Transition3     5'd3
`define Transition4     5'd4
`define Transition5     5'd5
`define Idle            5'd6
`define VddOn           5'd7
`define Wait1           5'd8
`define DispOff         5'd9
`define ResetOn         5'd10
`define Wait2           5'd11
`define ResetOff        5'd12
`define ChargePump1     5'd13
`define ChargePump2     5'd14
`define PreCharge1      5'd15
`define PreCharge2      5'd16
`define VbatOn          5'd17
`define Wait3           5'd18
`define DispContrast1   5'd19
`define DispContrast2   5'd20
`define InvertDisp1     5'd21
`define InvertDisp2     5'd22
`define ComConfig1      5'd23
`define ComConfig2      5'd24
`define ComConfig3      5'd25
`define ComConfig4      5'd26
`define ComConfig5      5'd27
`define DispOn          5'd28
`define FullDisp        5'd29
`define Done            5'd30

//for oled_exam.v
`define Transition1_e   5'd1
`define Transition2_e   5'd2
`define Transition3_e   5'd3
`define Transition4_e   5'd4
`define Transition5_e   5'd5
`define Idle_e          5'd6
`define ClearDC         5'd7
`define SetPage         5'd8
`define PageNum         5'd9
`define LeftColumn1     5'd10
`define LeftColumn2     5'd11
`define SetDC           5'd12
`define STR1            5'd13
`define Wait1_e         5'd14
`define STR2            5'd15
`define Wait2_e         5'd16
//`define DigilentScreen  5'd17
`define UpdateScreen    5'd18
`define SendChar1       5'd19
`define SendChar2       5'd20
`define SendChar3       5'd21
`define SendChar4       5'd22
`define SendChar5       5'd23
`define SendChar6       5'd24
`define SendChar7       5'd25
`define SendChar8       5'd26
`define ReadMem         5'd27
`define ReadMem2        5'd28
`define Done_e          5'd29
