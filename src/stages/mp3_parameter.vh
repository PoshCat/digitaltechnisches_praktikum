`define PARAMETER_WIDTH                              52

`define header_mode(compact)                         compact[1:0]
`define header_mode_extension(compact)               compact[3:2]	 
`define header_sampling_frequency(compact)           compact[5:4]		 

`define sideinfo_ch0_global_gain(compact)            compact[13:6]
`define sideinfo_ch0_window_switching_flag(compact)  compact[14]
`define sideinfo_ch0_block_type(compact)             compact[16:15]
`define sideinfo_ch0_mixed_block_flag(compact)       compact[17]
`define sideinfo_ch0_preflag(compact)                compact[18]
`define sideinfo_ch0_scalefac_scale(compact)         compact[19]

`define sideinfo_ch0_subblock_gain_window0(compact)  compact[22:20]
`define sideinfo_ch0_subblock_gain_window1(compact)  compact[25:23]
`define sideinfo_ch0_subblock_gain_window2(compact)  compact[28:26]

`define sideinfo_ch1_global_gain(compact)            compact[36:29]
`define sideinfo_ch1_window_switching_flag(compact)  compact[37]
`define sideinfo_ch1_block_type(compact)             compact[39:38]
`define sideinfo_ch1_mixed_block_flag(compact)       compact[40]
`define sideinfo_ch1_preflag(compact)                compact[41]
`define sideinfo_ch1_scalefac_scale(compact)         compact[42]

`define sideinfo_ch1_subblock_gain_window0(compact)  compact[45:43]
`define sideinfo_ch1_subblock_gain_window1(compact)  compact[48:46]
`define sideinfo_ch1_subblock_gain_window2(compact)  compact[51:49]