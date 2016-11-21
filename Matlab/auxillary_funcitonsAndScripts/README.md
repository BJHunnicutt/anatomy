### Helper functions required for various matlab functions

---
### Details about dependencies listed in the 'help' description of (most) matlab functions

#### Example: help jh_voxelClustering_striatum.m

    INPUTS: levels: (1-4) indicates the confidence levels to use for (clustering  - Used 3 for publication)
                  1 = diffuse
                  2 = diffuse and dense
                  3 = diffuse, intermediate, and dense
                  4 = dense only
              numberOfClusters: this determines the number of colored clusters (can be an array: [2 3 4 15])
              method: Enter number(s) of the clustering methods: (can also be an array to try several at once)
                  (1. 'correlation', 2. 'chebychev', 3. 'cityblock', 4. 'cosine', 5. 'euclidean', 6. 'hamming', 7. 'jaccard', 8. 'minkowski', 9. 'spearman');
                  (* Published with 9. 'spearman')
                figFlag (1 or 2)
                1. Generate cluster data, (save cluster description figs and clusterMasks_#clusters.mat)
                2. Quantify input sources of each cluster
                3. Plot input sources of each cluster
                4. A couple reordered versions of the plots created in 3
            saveFlag (0 or 1) do you want to save all the outputs from this

            ** To regenerate publication data: jh_voxelClustering_striatum(3, [2 3 4 15], 9, 1)

    OUTPUT: all cluster related data and figures

    PURPOSE: This takes the corticostriatal data and clusters striatal voxels based on cortical input similarity, and then quantifies properties of the resulting clusters

    DEPENDENCIES:
        /auxillary_funcitonsAndScripts/h_getNucleusOutline.m
        /auxillary_funcitonsAndScripts/h_imagesc.m
        'Image Processing Toolbox' ; 'Statistics and Machine Learning Toolbox'
