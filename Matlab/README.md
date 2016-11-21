## Generation/Analysis of Corticostriatal Data & Integration with Other Network Data:
> See [main anatomy README](https://github.com/BJHunnicutt/anatomy/blob/master/README.md) for overview

| File Name					| Purpose
| ----------------------------------|-------------
| 3. jh_pImport2matlab2.m			| Get AIBS data aligned & prepped for analysis
| 4. jh_AllenInstituteBundleSubtraction.m	| Remove bundled projections from AIBS data
| 5. jh_consolidatingAIBSdatasets.m	| Group injection data by cortical origin
| 6. jh_corticostriatalFigures.m | Generate figures for corticostriatal data alone
| 7. jh_voxelClustering_striatum.m | Create striatal subdivisions based on convergent cortical inputs
| 8. jh_consolidatingThalamusData.m | Get thalamic injections, group them, calculate coverage & nuclear coverage
| 9. jh_consolidatingAIBS_forNetworkAnalysis.m | Generate data for network analyses
| 10. jh_assortedStriatumFigures.m | Generate several example figures for methods and background


### Details about each step:
* (1-2 are [Python](https://github.com/BJHunnicutt/anatomy/tree/master/Python) functions)

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

#### 6. jh_corticostriatalFigures.m (matlab function)
* __Purpose__: generate figures for corticostriatal data alone
* __Location to run__: Anywhere, I generalized the file paths
* __Inputs__: injGroup_data.mat, inj_data.mat, outputs from jh_pImport2matlab2.m (all the rotatedData.mat files
and data_pImport.mat - was data_2015_04_28.mat
 and strmask_ic_submask.mat, averageTemplate100um_rotated.mat, averageTemplate100umACA_rotated.mat, AIBS_100um.mat
* __Outputs__: Various figures, images, and plots (save location is cd ../analyzed4/ from python output folder)
* __Saves__: Various figures, images, and plots
* __Running Notes__: Need to use saveFlag == 2 to save anything related to python output.

#### 7. jh_voxelClustering_striatum.m (matlab function)
* __Purpose__: create striatal subdivisions based on convergent cortical inputs
* __Location to run__:  Anywhere, I generalized the file paths
* __Inputs__: injGroup_data.mat, AIBS_100um.mat
* __Outputs__: Various figures, images, and plots related to clustering
* __Saves__: All cluster related figures and data
* __Running Notes__:  This was not run fully after updating the structure of this file.

#### 8. jh_consolidatingThalamusData.m (matlab function)
* __Purpose__: get thalamic injections, group them, calculate coverage & nuclear coverage
* __Location to run__: ‘/Users/jeaninehunnicutt/Desktop/Dynamic_Brain/MyProject/ThalamostriatalData_processed/’
* __Inputs__: so much... a lot of OLD thalamocortical data, injGroup_data.mat (and injGroups_AlloMesoNeo.mat etc), AIBS_100um.mat, clusterMasks_2clusters.mat (etc), colormaps, and MORE (tried to put things in matlab/masks/)
* __Outputs__: all thalamostriatal data and figures, and loop data/ plots
* __Saves__: inj_thalData.mat, thalamusInj_group_Level10.mat, etc...
* __Running Notes__: These files (particularly inj_thalData.mat) are large, and there are a lot of figures so its slow.

#### 9. jh_consolidatingAIBS_forNetworkAnalysis.m (matlab function)
* __Purpose__: Generate data for network analyses
* __Location to run__: filepaths still hardcoded
__Inputs__: output of GetDensityDataFromWeb.py, injGroup_data.mat, inj_data.mat, clusterMasks_4clusters.mat, corticalData_4clusters.mat, nuclearOrigins_thalToClusters_compositeMaps_20150624.mat, nuclearOrigins_compositeMaps.mat
* __Outputs__: edges and nodes for all network connections (details below).
* __Saves__: csv files of edges and nodes for: corticocortical (cortical subregion centric), corticostriatal (striatal custer centric), thalamostriatal (striatal custer centric), corticothalamic (cortical subregion centric), thalamocortical (cortical subregion centric), thalamostriatal (cortical subregion centric), corticostriatal (cortical subregion centric - fraction of field occupied - 3 levels), corticostriatal (cortical subregion centric - fraction of projection in field - 3 levels), basalgangia-thalamic (manual via literature), thalamocortical (striatal custer centric), corticothalamic (striatal custer centric).
* __Running Notes__:  manually added node centroids for thalamic nuclei.

#### 10. jh_assortedStriatumFigures.m (collection of matlab scripts)
* __Purpose__: Generate several example figures for methods and background
* __Inputs__: Various data from other functions
* __Outputs__: Figures
* __Saves__: Note: need to manually set saveFlag for each script to save the output
* __Running Notes__: Some file paths are not generalized, double check before running.
