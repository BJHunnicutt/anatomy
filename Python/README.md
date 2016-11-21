## Accessing Allen Institute Cortical Injection Data
> See [main anatomy overview](https://github.com/BJHunnicutt/anatomy/blob/master/README.md) for details


### Details about each step:
#### 1. jh_export2matlab4.py
* __Purpose__: Get the voxelized AIBS data for the striatum (CP + ACB) from python into matrices for matlab
* __Location to run__: anywhere as long as the data directory is correct, hard coded for my computer
* __Inputs__: Voxelized data from the AIBS: ‘raw_data’ folder, friday_harbor.structure, friday_harbor.mask, friday_harbor.experiment
* __Outputs__: voxPosL, voxDenL, voxPosInj, voxDenInj, voxDenAll (unmasked projection and injection info)
* __Saves__: the outputs above for all brain #s listed in the script as “region_specific_injs“
* __Running Notes__: data directory is hard coded for my computer

#### 2. jh_getDensityDataFromWeb.py
* __Purpose__:  Access the AIBS API to get the density and volume of projections to all other brain areas by each injection.
* __Location to run__: anywhere as long as the data directory is correct, hard coded for my computer
* __Inputs__: Voxelized data from the AIBS: ‘raw_data’ folder, AIBS API, friday_harbor.structure, friday_harbor.mask, friday_harbor.experiment
* __Outputs__: csv files with data formatted for Gephi (edges and nodes)
* __Saves__: 'structure_ids.csv' & 'edges.csv'
* __Running Notes__: data directory is hard coded for my computer


### AIBS experiments included in analysis:
---
Experiment ID    |	Cortical Group	|	Layer	|
---|---|---|
100140756	|	FrA	|	All
100140949	|	Rsp	|	All
100141219	|	Vis	|	All
100141599	|	Vis	|	All
100141796	|	Vis	|	All
100142655	|	S1/2	|	All
100148142	|	Rsp	|	All
100149109	|	Aud	|	All
112162251	|	S1/2	|	All
112229103	|	Ptl	|	All
112306316	|	LO/VO	|	All
112595376	|	Rsp	|	All
112596790	|	AI/GI/DI	|	All
112670853	|	M1/2	|	All
112881858	|	Aud	|	All
112936582	|	S1/2	|	All
113144533	|	Amyg	|	All
113887162	|	Vis	|	All
116903968	|	Vis	|	All
117298988	|	S1/2	|	All
120491896	|	Aud	|	All
120814821	|	M1/2	|	L5
120875816	|	S1/2	|	L5
121510421	|	Vis	|	L5
122641784	|	Sub	|	All
125832322	|	Amyg	|	All
126117554	|	d/vACC	|	L5
126908007	|	S1/2	|	All
127222723	|	Sub	|	All
127649005	|	Sub	|	All
127795906	|	Sub	|	All
139426984	|	d/vACC	|	All
139520203	|	d/vACC	|	All
141602484	|	M1/2	|	All
142656218	|	Rhi/Tem	|	All
146077302	|	Vis	|	All
146858006	|	Aud	|	All
152994878	|	Sub	|	All
156394513	|	M1/2	|	L5
156493815	|	Aud	|	L5
156741826	|	LO/VO	|	L5
157062358	|	Rhi/Tem	|	All
157063781	|	Sub	|	All
157556400	|	IL	|	All
157654817	|	S1/2	|	All
157710335	|	FrA	|	All
157711748	|	PrL/MO	|	All
158255941	|	Vis	|	L5
158314278	|	Aud	|	All
158435116	|	LO/VO	|	All
159319654	|	d/vACC	|	L5
159832064	|	Rsp	|	L5
161458737	|	d/vACC	|	L5
166054929	|	Rsp	|	L5
166082128	|	M1/2	|	L5
166083557	|	Rhi/Tem	|	L5
166153483	|	AI/GI/DI	|	L5
166271142	|	Rsp	|	L5
166323186	|	S1/2	|	L5
166323896	|	d/vACC	|	L5
166324604	|	Vis	|	L5
166461899	|	Vis	|	L5
167794131	|	Vis	|	L5
168002073	|	M1/2	|	L234
168003640	|	S1/2	|	L234
168163498	|	S1/2	|	L5
168164972	|	LO/VO	|	L5
168165712	|	Ptl	|	L5
171276330	|	S1/2	|	L5
174361746	|	AI/GI/DI	|	All
176430283	|	Aud	|	L234
178488859	|	Sub	|	NA
180719293	|	M1/2	|	All
180917660	|	AI/GI/DI	|	All
181600380	|	Aud	|	L5
182226839	|	Sub	|	NA
182294687	|	Amyg	|	NA
182467026	|	S1/2	|	L5
182616478	|	M1/2	|	L234
182794184	|	Rhi/Tem	|	L5
183461297	|	d/vACC	|	L234
183470468	|	d/vACC	|	L234
183471174	|	LO/VO	|	L234
184167484	|	Ptl	|	L234
184168899	|	AI/GI/DI	|	L234
263106036	|	PrL/MO	|	L5
263242463	|	FrA	|	L5
263780729	|	Vis	|	L234
264629246	|	S1/2	|	L5
264630019	|	Vis	|	L5
266486371	|	S1/2	|	L234
266487079	|	Vis	|	L234
266644610	|	S1/2	|	L234
272414403	|	Rhi/Tem	|	All
272735030	|	S1/2	|	L5
272735744	|	Rsp	|	L234
272737914	|	AI/GI/DI	|	All
272821309	|	Vis	|	L234
277710753	|	Amyg	|	All
278317239	|	Rhi/Tem	|	L234
278317945	|	S1/2	|	L234
283019341	|	PrL/MO	|	L5
283020912	|	Vis	|	L5
286299886	|	FrA	|	L234
286300594	|	S1/2	|	L234
286312782	|	S1/2	|	L5
286313491	|	IL	|	L5
286610216	|	Sub	|	NA
286610923	|	Sub	|	NA
287494320	|	IL	|	L234
287495026	|	Vis	|	L234
287769286	|	LO/VO	|	L5
292373346	|	Rsp	|	L5
292374068	|	M1/2	|	L5
292374777	|	PrL/MO	|	L5
292476595	|	FrA	|	L5
292532065	|	Sub	|	NA
292792016	|	S1/2	|	L5
292792724	|	Ptl	|	L5
293471629	|	PrL/MO	|	L234
294396492	|	PrL/MO	|	L234
294481346	|	Vis	|	L5
294482052	|	Vis	|	L5
294484177	|	Rsp	|	L234
296048512	|	AI/GI/DI	|	L5
297652799	|	S1/2	|	L5
298324391	|	Vis	|	L5
