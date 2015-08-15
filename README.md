## Documentation of Anatomy Analysis Code
---
> This is the analysis code for my PhD thesis work: "A comprehensive map of excitatory input convergence in the mouse striatum." The corticostriatal dataset was generated by the Allen Institute for Brain Science (AIBS) & the thalamostriatal dataset generated in my lab (publication in preparation).

### Data Sources:
---
[Thalamic Projections](http://digitalcollections.ohsu.edu/projectionmap)
: Hunnicutt, B. J. et al. (2014). A comprehensive thalamocortical projection map at the mesoscopic level. Nature Neuroscience. 17, 1276–1285.

[Cortical Projections](http://connectivity.brain-map.org/projection)
: Oh, S. W. et al. (2014). A mesoscale connectome of the mouse brain. Nature 508, 207–214.



### Overview of Analysis Code (in order):
---
| File Name					|	Purpose
| ----------------------------------|-------------
| 1. jh_export2matlab4.py			|	Get voxelized AIBS data out of python
| 2. jh_GetDensityDataFromWeb.py	|	Access density data from AIBS API
| 3. jh_pImport2matlab2.m			|	Get AIBS data aligned & prepped for analysis
| 4. jh_AllenInstituteBundleSubtraction.m	|	Remove bundled projections from AIBS data
| 5. jh_consolidatingAIBSdatasets.m	|	Group injections data by cortical origin
| 6. 

	 
### Details about each step:
---
#### 1. jh_export2matlab4.py (python)
* __Purpose__: Get the voxelized AIBS data for the striatum (CP + ACB) from python into matrices for matlab
* __Inputs__: Voxelized data & python libraries from the AIBS: ‘raw_data’ folder, friday_harbor.structure, friday_harbor.mask, friday_harbor.experiment 
* __Outputs__: voxPosL, voxDenL, voxPosInj, voxDenInj, voxDenAll (unmasked projection and injection info)
* __Saves__: the outputs above for all brain #s listed in the script as “region_specific_injs“
* __Running Notes__: data directory is hard coded for my computer

#### 2. jh_getDensityDataFromWeb.py (python) 
* __Purpose__:  Access the AIBS API to get the density and volume of projections to all other brain areas by each injection.
* __Inputs__: Voxelized data from the AIBS: ‘raw_data’ folder, AIBS API, friday_harbor.structure, friday_harbor.mask, friday_harbor.experiment
* __Outputs__: csv files with data formatted for Gephi (edges and nodes)
* __Saves__: 'structure_ids.csv' & 'edges.csv'
* __Running Notes__: data directory is hard coded for my computer

#### 3. jh_pImport2matlab2.m (matlab function)
* __Purpose__: Imports the data from ‘jh_export2matlab4.py’, puts it in a matrix, rotates it to be coronal, masks the density data to my model striatum, & creates a data folder with tiffs for each experiment
* __Inputs__: directory path to the output of jh_export2matlab4.py, saveFlag (0 or 1)
* __Outputs__: rotatedData, data (these are the final density matrices for each AIBS experiment)
* __Saves__: outputs, average template brain, tiffs with the injection/projection overlaid on the template brain
* __Running Notes__: Creating tiffs for each experiment in the last section, which is very slow

#### 4. jh_AllenInstituteBundleSubtraction.m (matlab GUI)
* __Purpose__: To remove bundled projections that the AIBS data counts as terminals
* __Inputs__: rotatedData.mat, injMeta.mat, averageTemplate100um_rotated.mat
* __Outputs__: submask.mat
* __Saves__: submask and also updates injMeta.mat
* __Running Notes__: This is a manual step to apply to all AIBS data. This is a GUI so it must have 
the jh_AllenInstituteBundleSubtraction.fig file in the same path. (Notes on manual steps on Google Drive as: AIBS Bundle Subtraction Notes)
Be in the AIBS experiment folder to execute the function: e.g. /Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/data3/100140756

#### 5. jh_consolidatingAIBSdatasets.m (matlab function)
* __Purpose__: group injections from the same cortical area
* __Inputs__: Outputs from jh_pImport2matlab2.m and jh_AllenInstituteBundleSubtraction, and strmask_ic_submask.mat, averageTemplate100um_rotated.mat, averageTemplate100umACA_rotated.mat, AIBS_100um.mat. 
* __Outputs__: injGroup_data, inj_data, 
* __Saves__: injGroup_data.mat, inj_data.mat
* __Running Notes__:
	
#### 6. jh_voxelClustering_striatum3.m
* __Purpose__: 
* __Inputs__:
* __Outputs__:
* __Saves__:
* __Running Notes__:
	
#### 7. jh_voxelClustering_striatum3.m
* __Purpose__: 
* __Inputs__:
* __Outputs__:
* __Saves__:
* __Running Notes__:
	
#### 8. jh_consolidatingThalamusData.m
* __Purpose__: get thalamic injections, group them, calculate coverage & nuclear coverage
* __Inputs__:
* __Outputs__:
* __Saves__:
* __Running Notes__:
	
#### 9. jh_consolidatingAIBSdatasets_forGephi.m
* __Purpose__: (not used yet...)
* __Inputs__:
* __Outputs__:
* __Saves__:
* __Running Notes__:
	
#### jh_assortedStriatumFigures_postThesis.m
* __Purpose__: 
* __Inputs__:
* __Outputs__:
* __Saves__:
__Running Notes__:

### Where Figures are Made:
---
* Figure 1
* Figure 2
* Figure 3
* Figure 4
* Figure 5
* Figure 6
* Figure 7
* Figure 8
