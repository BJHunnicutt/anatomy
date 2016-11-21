# Documentation of Anatomy Analysis Code
> This is the analysis code for the striatal portion of my PhD thesis work: "A comprehensive map of excitatory input convergence in the mouse striatum." The corticostriatal dataset was generated from data produced by the [Allen Institute for Brain Science](http://connectivity.brain-map.org/projection) (AIBS) & the thalamostriatal dataset generated from data produced by us for a [previous study](http://digitalcollections.ohsu.edu/projectionmap).

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
| 1. jh_export2matlab4.py*			|	Get voxelized AIBS data out of python
| 2. jh_GetDensityDataFromWeb.py*	|	Access density data from AIBS API
| 3. jh_pImport2matlab2.m*			|	Get AIBS data aligned & prepped for analysis
| 4. jh_AllenInstituteBundleSubtraction.m*	|	Remove bundled projections from AIBS data
| 5. jh_consolidatingAIBSdatasets.m*	|	Group injection data by cortical origin
| 6. jh_corticostriatalFigures.m* | Generate figures for corticostriatal data alone
| 7. jh_voxelClustering_striatum.m* | Create striatal subdivisions based on convergent cortical inputs
| 8. jh_consolidatingThalamusData.m* | Get thalamic injections, group them, calculate coverage & nuclear coverage
| 9. jh_consolidatingAIBS_forNetworkAnalysis.m* | Generate data for network analyses
| 10. jh_assortedStriatumFigures.m* | Generate several example figures for methods and background



### Details about each step:
---
#### 1. jh_export2matlab4.py (python)
* __Purpose__: Get the voxelized AIBS data for the striatum (CP + ACB) from python into matrices for matlab
* __Location to run__: anywhere as long as the data directory is correct, hard coded for my computer
* __Inputs__: Voxelized data from the AIBS: ‘raw_data’ folder, friday_harbor.structure, friday_harbor.mask, friday_harbor.experiment
* __Outputs__: voxPosL, voxDenL, voxPosInj, voxDenInj, voxDenAll (unmasked projection and injection info)
* __Saves__: the outputs above for all brain #s listed in the script as “region_specific_injs“
* __Running Notes__: data directory is hard coded for my computer

#### 2. jh_getDensityDataFromWeb.py (python)
* __Purpose__:  Access the AIBS API to get the density and volume of projections to all other brain areas by each injection.
* __Location to run__: anywhere as long as the data directory is correct, hard coded for my computer
* __Inputs__: Voxelized data from the AIBS: ‘raw_data’ folder, AIBS API, friday_harbor.structure, friday_harbor.mask, friday_harbor.experiment
* __Outputs__: csv files with data formatted for Gephi (edges and nodes)
* __Saves__: 'structure_ids.csv' & 'edges.csv'
* __Running Notes__: data directory is hard coded for my computer

#### 3. jh_pImport2matlab2.m (matlab function)
* __Purpose__: Imports the data from ‘jh_export2matlab4.py’, puts it in a matrix, rotates it to be coronal, masks the density data to my model striatum, & creates a data folder with tiffs for each experiment
* __Location to run__: anywhere, I generalized the file paths
* __Inputs__: directory path to the output of jh_export2matlab4.py, saveFlag (0 or 1)
* __Outputs__: rotatedData, data (these are the density matrices for each AIBS experiment)
* __Saves__: outputs, average template brain, tiffs with the injection/projection overlaid on the template brain
* __Running Notes__: Creating tiffs for each experiment in the last section, which is very slow

#### 4.jh_AllenInstituteBundleSubtraction.m (matlab GUI)
* __Purpose__: To remove bundled projections that the AIBS data counts as terminals
* __Location to run__: In the AIBS experiment folder: e.g. /Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/data3/100140756
* __Inputs__: rotatedData.mat, injMeta.mat, averageTemplate100um_rotated.mat
* __Outputs__: submask.mat
* __Saves__: submask and also updates injMeta.mat
* __Running Notes__: This is a manual step to apply to all AIBS data. This is a GUI so it must have the jh_AllenInstituteBundleSubtraction.fig file in the same path. Notes on Google Drive as: AIBS Bundle Subtraction Notes

#### 5. jh_consolidatingAIBSdatasets.m (matlab function)
* __Purpose__: group injections from the same cortical area
* __Location to run__: Anywhere, I generalized the file paths
* __Inputs__: Outputs from jh_pImport2matlab2.m and jh_AllenInstituteBundleSubtraction, and strmask_ic_submask.mat, averageTemplate100um_rotated.mat, averageTemplate100umACA_rotated.mat, AIBS_100um.mat.
* __Outputs__: injGroup_data, inj_data, (save location is hardcoded as cd ../analyzed4/ from python output folder)
* __Saves__: injGroup_data.mat, inj_data.mat
* __Running Notes__: Need to use saveFlag == 2 to save anything related to python output.

#### 6. jh_corticostriatalFigures.m (matlab function)* __Purpose__: generate figures for corticostriatal data alone* __Location to run__: Anywhere, I generalized the file paths* __Inputs__: injGroup_data.mat, inj_data.mat, outputs from jh_pImport2matlab2.m (all the rotatedData.mat filesand data_pImport.mat - was data_2015_04_28.mat and strmask_ic_submask.mat, averageTemplate100um_rotated.mat, averageTemplate100umACA_rotated.mat, AIBS_100um.mat* __Outputs__: Various figures, images, and plots (save location is cd ../analyzed4/ from python output folder)* __Saves__: Various figures, images, and plots* __Running Notes__: Need to use saveFlag == 2 to save anything related to python output.#### 7. jh_voxelClustering_striatum.m (matlab function)* __Purpose__: create striatal subdivisions based on convergent cortical inputs* __Location to run__:  Anywhere, I generalized the file paths* __Inputs__: injGroup_data.mat, AIBS_100um.mat* __Outputs__: Various figures, images, and plots related to clustering* __Saves__: All cluster related figures and data* __Running Notes__:  This was not run fully after updating the structure of this file.#### 8. jh_consolidatingThalamusData.m (matlab function)* __Purpose__: get thalamic injections, group them, calculate coverage & nuclear coverage* __Location to run__: ‘/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/ThalamostriatalData_processed/’* __Inputs__: so much... a lot of OLD thalamocortical data, injGroup_data.mat (and injGroups_AlloMesoNeo.mat etc), AIBS_100um.mat, clusterMasks_2clusters.mat (etc), colormaps, and MORE (tried to put things in matlab/masks/)* __Outputs__: all thalamostriatal data and figures, and loop data/ plots* __Saves__: inj_thalData.mat, thalamusInj_group_Level10.mat, etc...* __Running Notes__: These files (particularly inj_thalData.mat) are large, and there are a lot of figures so its slow.#### 9. jh_consolidatingAIBS_forNetworkAnalysis.m (matlab function)* __Purpose__: Generate data for network analyses* __Location to run__: filepaths still hardcoded__Inputs__: output of GetDensityDataFromWeb.py, injGroup_data.mat, inj_data.mat, clusterMasks_4clusters.mat, corticalData_4clusters.mat, nuclearOrigins_thalToClusters_compositeMaps_20150624.mat, nuclearOrigins_compositeMaps.mat* __Outputs__: edges and nodes for all network connections (details below).* __Saves__: csv files of edges and nodes for: corticocortical (cortical subregion centric), corticostriatal (striatal custer centric), thalamostriatal (striatal custer centric), corticothalamic (cortical subregion centric), thalamocortical (cortical subregion centric), thalamostriatal (cortical subregion centric), corticostriatal (cortical subregion centric - fraction of field occupied - 3 levels), corticostriatal (cortical subregion centric - fraction of projection in field - 3 levels), basalgangia-thalamic (manual via literature), thalamocortical (striatal custer centric), corticothalamic (striatal custer centric).* __Running Notes__:  manually added node centroids for thalamic nuclei.#### 10. jh_assortedStriatumFigures.m (collection of matlab scripts)* __Purpose__: Generate several example figures for methods and background
* __Inputs__: Various data from other functions
* __Outputs__: Figures
* __Saves__: Note: need to manually set saveFlag for each script to save the output
* __Running Notes__: Some file paths are not generalized, double check before running.


---
### Thalamostriatal Data Generation:
 * (/Matlab/thalamostriatal/\*)  

| File Name					|	Purpose
| ----------------------------------|-------------
| 1. jh_segmentstriatum.m | Create manual striatum masks
| 2. jh_strRot.m | Manually select striatal landmarks used for alignment
| 3. jh_checkingStrPts.m | Check manually selected points
| 4. jh_createStrMaskedTiffs.m | Generate tiffs cropped by the striatum mask
| --> WEKA Image Segmentation machine learning algorythm implemented via ImageJ | Select and train image subset, then apply WEKA machine learning (ML) algorithm to all images. Output => WEKA Probability Images for diffuse projection localization
| 5. jh_threshold_WEKA.m | GUI to manually select probability thresholds ( Requires: jh_threshold_WEKA.fig)
| 6. jh_WEKAprobToMask.m | Apply the selected thresholds to the probability masks
| 7. jh_finalProjMaskAdjustments_green.m | Manual correction of small errors in automated WEKA ML output for green channel (Requires: jh_finalProjMaskAdjustments_green.fig)
| 8. jh_finalProjMaskAdjustments_red.m | Manual correction of small errors in automated WEKA ML output for red channel (Requires: jh_finalProjMaskAdjustments_red.fig)
| 9. jh_createFinalProjMasks.m | Generate final projection masks that include manual adjustments and holes caused be traveling axons filled
| 10. jh_createFinalProjMasks_fixaddMaskMistake.m | Ran after jh_createFinalProjMasks.m to fix a small error.

##### See: */Matlab/thalamostriatal/README.md* for implementation details.


<!-- | jh_trainedStrProjMaskGen.m | Creates colormask.mat to subract aberrantly localized projections * Originally did this after jh_WEKAprobToMask.m, then refined with jh_finalProjMaskAdjustments... GUIs, but jsut starting with the GIUS works too-->

---
### Other Information:
##### Required Matlab Functionality:
* 'Image Processing Toolbox' & 'Statistics and Machine Learning Toolbox'

##### Helper functions required for the code above:
* See: */Matlab/auxillary_funcitonsAndScripts/...*

##### Collection of template masks, data, and settings required above:
* See: */Matlab/masks/...*

##### Striatum alignment for thalamostriatal data:
* See: */Matlab/striatum_alignment/...*
* *Currently in the .gitignore - Need to ask Haining about putting this code in here with attribution*


### Other Information:
##### Required Matlab Functionality:
* 'Image Processing Toolbox' & 'Statistics and Machine Learning Toolbox'

##### Helper functions required for the code above:
* See: */Matlab/auxillary_funcitonsAndScripts/...*

##### Collection of template masks, data, and settings required above:
* See: */Matlab/masks/...*

##### Striatum alignment for thalamostriatal data:
* See: */Matlab/striatum_alignment/...*
* Currently in the .gitignore - Need to ask Haining about putting this code in here with attribution
