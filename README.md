# Documentation of all anatomy analysis code

### Corticostriatal: Start to Finish:
 * jh_export2matlab4.py
 * jh_GetDensityDataFromWeb.py
 * jh_pImport2matlab2.m
 * jh_AllenInstituteBundleSubtraction
 * jh_consolidatingAIBSdatasets.m
 
### Thalamostriatal: Start to Finish:
* 
* 

	 
### Details about Scripts & Functions:
#### jh_export2matlab4.py
* __Purpose__: Get the voxelized data for the striatum (CP + ACB) from python into matrices for matlab
* __Old File Location__: /Users/jeaninehunnicutt/Desktop/Dynamic_Brain/GroupProject/pCode/export2matlab4_jh.py
* __Changes during cleanup__:
* __Location to run__: anywhere as long as the data directory is correct, hard coded for my computer
* __Inputs__: Voxelized data from the AIBS: ‘raw_data’ folder, friday_harbor.structure, friday_harbor.mask, friday_harbor.experiment
* __Outputs__: voxPosL, voxDenL, voxPosInj, voxDenInj, voxDenAll (unmasked projection and injection info)
* __Saves__: the outputs above for all brain #s listed in the script as “region_specific_injs“
* __Running Notes__: 

#### jh_getDensityDataFromWeb.py 
* __Purpose__:  Access the AIBS API to get the density and volume of projections to all other brain areas by each injection.
* __Old File Location__: /Users/jeaninehunnicutt/Desktop/Dynamic_Brain/GroupProject2/ GetDensityDataFromWeb.py
* __Changes during cleanup__:
* __Location to run__: anywhere as long as the data directory is correct, hard coded for my computer
* __Inputs__: Voxelized data from the AIBS: ‘raw_data’ folder, AIBS API, friday_harbor.structure, friday_harbor.mask, friday_harbor.experiment
* __Outputs__: csv files with data formatted for Gephi (edges and nodes)
* __Saves__: 'structure_ids.csv' & 'edges.csv'
* __Running Notes__:

#### jh_pImport2matlab2.m (function)
* __Purpose__: Imports the data from ‘jh_export2matlab4.py’, puts it in a matrix, rotates it to be coronal, masks the density data to my model striatum, & creates a data folder with tiffs for each experiment
* __Old File Location__: /Users/jeaninehunnicutt/Desktop/Dynamic_Brain/GroupProject/pCode/
* __Changes during cleanup__: Turned it into a function, generalized file paths
* __Location to run__: anywhere, I generalized the file paths
* __Inputs__: directory path to the output of jh_export2matlab4.py, saveFlag (0 or 1)
* __Outputs__: rotatedData, data (these are the final density matrices for each AIBS experiment)
* __Saves__: outputs, average template brain, tiffs with the injection/projection overlaid on the template brain
* __Running Notes__: Run the whole script once, or run section by section (i.e. the %% chunks) creating tiffs for each experiment in the last section, which will be very slow

#### jh_AllenInstituteBundleSubtraction (GUI)
* __Purpose__: To remove bundled projections that the AIBS data counts as terminals
* __Old File Location__: /Users/jeaninehunnicutt/Desktop/Striatum Project/StriatumAnatomyCode/MATLAB/inPath
* __Location to run__: In the AIBS experiment folder: e.g. /Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/data3/100140756
* __Inputs__: rotatedData.mat, injMeta.mat, averageTemplate100um_rotated.mat
* __Outputs__: submask.mat
* __Saves__: submask and also updates injMeta.mat
* __Running Notes__: This is a manual step to apply to all AIBS data. This is a GUI so it must have the jh_AllenInstituteBundleSubtraction.fig file in the same path 
	Notes on Google Drive as: AIBS Bundle Subtraction Notes

#### jh_consolidatingAIBSdatasets.m
* __Purpose__: group injections from the same cortical area
* __Old File Location__: /Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject
* __Changes during cleanup__: Made it a function, generalized filepaths, 
* __Location to run__: Anywhere, I generalized the file paths
* __Inputs__: Outputs from jh_pImport2matlab2.m and jh_AllenInstituteBundleSubtraction, and strmask_ic_submask.mat, averageTemplate100um_rotated.mat, averageTemplate100umACA_rotated.mat, AIBS_100um.mat. 
* __Outputs__: injGroup_data, inj_data, 
* __Saves__: injGroup_data.mat, inj_data.mat
* __Running Notes__:
	
#### jh_voxelClustering_striatum3.m
* __Purpose__: 
* __Old File Location__: 
* __Location to run__:
* __Inputs__:
* __Outputs__:
* __Saves__:
* __Running Notes__:
	
#### jh_consolidatingThalamusData.m
* __Purpose__: get thalamic injections, group them, calculate coverage & nuclear coverage
* __Old File Location__: 
* __Location to run__:
* __Inputs__:
* __Outputs__:
* __Saves__:
* __Running Notes__:
	
#### jh_consolidatingAIBSdatasets_forGephi.m
* __Purpose__: (not used yet...)
* __Old File Location__: 
* __Location to run__:
* __Inputs__:
* __Outputs__:
* __Saves__:
* __Running Notes__:
	
	jh_corticalstratal_notes.m (spelled this way)
* __Purpose__: 
* __Old File Location__: 
* __Location to run__:
* __Inputs__:
* __Outputs__:
* __Saves__:
* __Running Notes__:
	
	jh_assortedStriatumFigures_postThesis.m
* __Purpose__: 
* __Old File Location__: 
* __Location to run__:
* __Inputs__:
* __Outputs__:
* __Saves__:
* __Running Notes__:


### Where Thesis Figures are Made:
Figure 1
Figure 2
Figure 3
Figure 4
Figure 5
Figure 6
Figure 7
Figure 8

Analyzed Data Locations:
	- Primarily: ~/Desktop/Dynamic_Brain/MyProject/analyzed3
	- ~/Desktop/Dynamic_Brain/MyProject/geph_forThesis (yes, misspelled)
	- ~/Desktop/Thesis
	- ~/Desktop/Straitum Project/2P  **This was moved, matlab may want 2P on the desktop
	- ~/Desktop/Straitum Project/StriatumPaper/Figures  **I put bundled/diffuse data here


Interactive Data Visualizations:

Gephi: (other notes in red notebook)
	Testing with old data:
		-Flip the D-V (Y) axis
		
	Want: 
		-a way to have all of the clustering threshods in one plot... Grouping?
		-cluster sizes to reflect cluster volume
		-if I do one with the individual injections, then group them by subregion
		-get the inj ID in the graphic
	At end:
		-Remove Oxford Logo
		-Add links to Tianyi’s website, our data site?, and the allen instiute