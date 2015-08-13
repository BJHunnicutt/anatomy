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
#### jh_export2matlab4.py (PYTHON)
	* Purpose: Get the voxelized data for the striatum (CP + ACB) from python into matrices for matlab
	* Old File Location: /Users/jeaninehunnicutt/Desktop/Dynamic_Brain/GroupProject/pCode/export2matlab4_jh.py
	* Changes during cleanup:
	* Location to run: anywhere as long as the data directory is correct, hard coded for my computer
	* Inputs: Voxelized data from the AIBS: ‘raw_data’ folder, friday_harbor.structure, friday_harbor.mask, friday_harbor.experiment
	* Outputs: voxPosL, voxDenL, voxPosInj, voxDenInj, voxDenAll (unmasked projection and injection info)
	* Saves: the outputs above for all brain #s listed in the script as “region_specific_injs“
	* Running Notes: 

	jh_getDensityDataFromWeb.py (PYTHON)
- Purpose: Access the AIBS API to get the density and volume of projections to all other brain areas by each injection.
Old File Location: /Users/jeaninehunnicutt/Desktop/Dynamic_Brain/GroupProject2/ GetDensityDataFromWeb.py
Changes during cleanup:
Location to run: anywhere as long as the data directory is correct, hard coded for my computer
Inputs: Voxelized data from the AIBS: ‘raw_data’ folder, AIBS API, friday_harbor.structure, friday_harbor.mask, friday_harbor.experiment
Outputs: csv files with data formatted for Gephi (edges and nodes)
Saves: 'structure_ids.csv' & 'edges.csv'
Running Notes:

	jh_pImport2matlab2.m (function)
- Purpose: Imports the data from ‘jh_export2matlab4.py’, puts it in a matrix, rotates it to be coronal, masks the density data to my model striatum, & creates a data folder with tiffs for each experiment
Old File Location: /Users/jeaninehunnicutt/Desktop/Dynamic_Brain/GroupProject/pCode/
Changes during cleanup: Turned it into a function, generalized file paths
Location to run: anywhere, I generalized the file paths
Inputs: directory path to the output of jh_export2matlab4.py, saveFlag (0 or 1)
Outputs: rotatedData, data (these are the final density matrices for each AIBS experiment)
Saves: outputs, average template brain, tiffs with the injection/projection overlaid on the template brain
Running Notes: Run the whole script once, or run section by section (i.e. the %% chunks) 
creating tiffs for each experiment in the last section, which will be very slow

	jh_AllenInstituteBundleSubtraction (GUI)
		- Purpose: To remove bundled projections that the AIBS data counts as terminals
Old File Location: /Users/jeaninehunnicutt/Desktop/Striatum Project/StriatumAnatomyCode/MATLAB/inPath
Location to run: In the AIBS experiment folder: e.g. /Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/data3/100140756
Inputs: rotatedData.mat, injMeta.mat, averageTemplate100um_rotated.mat
Outputs: submask.mat
Saves: submask and also updates injMeta.mat
Running Notes: This is a manual step to apply to all AIBS data. 
This is a GUI so it must have the jh_AllenInstituteBundleSubtraction.fig file in the same path 
Notes on Google Drive as: AIBS Bundle Subtraction Notes

	jh_consolidatingAIBSdatasets.m
- Purpose: group injections from the same cortical area
Old File Location: /Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject
Changes during cleanup: Made it a function, generalized filepaths, 
Location to run: Anywhere, I generalized the file paths
Inputs: Outputs from jh_pImport2matlab2.m and jh_AllenInstituteBundleSubtraction, and strmask_ic_submask.mat, averageTemplate100um_rotated.mat, averageTemplate100umACA_rotated.mat, AIBS_100um.mat. 
Outputs: injGroup_data, inj_data, 
Saves: injGroup_data.mat, inj_data.mat
Running Notes:
	
	jh_voxelClustering_striatum3.m
- Purpose: 
Old File Location: 
Location to run:
Inputs:
Outputs:
Saves:
Running Notes:
	
	jh_consolidatingThalamusData.m
- Purpose: get thalamic injections, group them, calculate coverage & nuclear coverage
Old File Location: 
Changes during cleanup:
Location to run:
Inputs:
Outputs:
Saves:
Running Notes:
	
	jh_consolidatingAIBSdatasets_forGephi.m
- Purpose: (not used yet...)
Old File Location: 
Changes during cleanup:
Location to run:
Inputs:
Outputs:
Saves:
Running Notes:
	
	jh_corticalstratal_notes.m (spelled this way)
- Purpose: 
Old File Location: 
Changes during cleanup:
Location to run:
Inputs:
Outputs:
Saves:
Running Notes:
	
	jh_assortedStriatumFigures_postThesis.m
- Purpose: 
Old File Location: 
Changes during cleanup:
Location to run:
Inputs:
Outputs:
Saves:
Running Notes:


Where Thesis Figures are Made:
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
