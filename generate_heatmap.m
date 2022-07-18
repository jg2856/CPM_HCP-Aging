%% Written by Jordan Galbraith 7/17/2022

%example command line: generate_heatmap("rfMRI_REST1_AP","HCA6002236")
%Purpose: create full 268x268 heatmap separated out by network
%Inputs: scan type of interest ('rfMRI_REST1_AP', 'rfMRI_REST1_PA', 'rfMRI_REST2_AP',
    %'rfMRI_REST2_PA','tfMRI_CARIT', 'tfMRI_FACENAME', 'tfMRI_VISMOTOR'), and
    %pt number
%Output: prints out heatmap


function generate_heatmap(scan, pt)


% load conn mat of interest
load(sprintf('C:/Users/jogal/Yale University/Ju, Suyeon - CPM_HCP-A/BIG_data_from_CPM_HCP-Aging/all_conn_mats.mat'), 'conn_mat_struct_all');
conn_matrix = conn_mat_struct_all.(scan).(pt);

%reorder to put 10 networks in order
correct_Shen_order = [10 12	16 52 53 54 56 57 64 65 137 140 145	148	149	150	151	153	156	162	165	183	185	186	187	190	192	194	219	1 4	7 8	9 14 17	19 21 22 30	31 47 48 55	70 111 112 116 139 142 143 147 154 157 164 182 184 193 196 199 242 246 247 3 5 6 13	49 50 85 86	90 96 115 134 138 141 203 222 223 225 227 239 23 24	25 26 27 33	34	35	37	38	39	40	45	46	51	58	60	61	62	63	84	89	92	97	109	158	159	160	161	163	166	167	168	170	171	172	173	174	179	180	181	188	189	191	195	197	202	218	228	235	42	68	72	75	77	79	80	82	87	98	176	198	205	207	208	211	215	216	76	78	81	100	102	212	213	214	241	41	43	59	66	67	69	71	73	74	175	177	200	201	204	206	209	210	240	2 11 15	18	20	28	29	32	36	44	83	88	91	110	119	135	136	144	146	152	155	169	178	220	221	224	226	244	245	251	93	94	95	99 120	121	122	123	124	125	126	127	128	217	229	230	231	232	233	234	257	258	259	260	261	262	263	264	265	101	103	104	105	106	107	108	113	114	117	118	129	130	131	132	133	236	237	238	243	248	249	250	252	253	254	255	256	266	267	268];
size(correct_Shen_order)
conn_matrix = conn_matrix(correct_Shen_order,correct_Shen_order);

%get rid of correlations of nodes to themselves
conn_matrix(conn_matrix > 6) = 0;

%create heatmap with no grid lines
conn_heatmap = heatmap(conn_matrix,'GridVisible','off','Colormap', jet);

%Get rid of x labels
cdl = conn_heatmap.XDisplayLabels;                                    
conn_heatmap.XDisplayLabels = repmat(' ',size(cdl,1), size(cdl,2));

%Get rid of y labels
cd2 = conn_heatmap.YDisplayLabels;                                    
conn_heatmap.YDisplayLabels = repmat(' ',size(cd2,1), size(cd2,2));

%create lines and tick labels to overlay on heatmap
a2 = axes('Position', conn_heatmap.Position);               
a2.Color = 'none';   %new axis transparent

%Place lines to separate networks - based on Shen atlas excel doc
yline(a2,[29 63 83 133 151 160 178 208 237],'LineWidth', 0.9); 
xline(a2,[29 63 83 133 151 160 178 208 237],'LineWidth', 0.9);

%Halfway between each line to add in network labels
a2.YTick = [14.5 46 73 108 142 155.5 169 193 222.5 252.5];              
a2.XTick = [14.5 46 73 108 142 155.5 169 193 222.5 252.5]; 

%So we don't see the ticks and just use them to place labels
a2.XAxis.TickLength = [0 0];
a2.YAxis.TickLength = [0 0];

%flip your y axis to correspond with heatmap's
a2.YDir = 'Reverse';       

%Add in labels for networks
a2.YTickLabel = {'MF','FP','DMN','Mot','VI','VII','VAs','SAL','SC','CBL'}; 
a2.XTickLabel = {'MF','FP','DMN','Mot','VI','VII','VAs','SAL','SC','CBL'};

%center the tick marks - otherwise leaves out CBL for some reason
ylim(a2, [0.5, size(conn_heatmap.ColorData,1)+.5])         
xlim(a2, [0.5, size(conn_heatmap.ColorData,1)+.5])          






