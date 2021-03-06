function [ per_video ] = ranked_retrieve( video_query_features, pca_mapping,itq_rot_mat, hash_table, min_change, mapped, max_return, retrieve_by_motion, make_unique )
% get query video features and returens a ranked list of similar videos
% from dataset.
%   input:
%       -video_query_features : video frames extracted feature_vectors
%       -pca_mapping:
%       -itq_rot_mat: ITQ train data
%       -hash_table: Cellarray, Video hash table 
%           [ [hash_code] , [video_nos, frame_nos] , [binaries] ]
%       -min_change : minimum number of bit change to consider as key_frame
%       -frames_table: table of videos key_frames
%       -mapped: dataset mapped table and annotations.
%       -query_no: video sample index in test dataset
%       -max_return: maximum result number need to retrieve
%       -retrieve_by_motion : to retrieve based on motion_vectors set
%           retrieve_by_motion=true
%       -make_unique : cosider unique frames in each retrieved video sample.
%                      (Default = ture)
%
%   output:
%       -per_video: ranked list of videos in dataset, according to
%       frequently in common frames between query video
%       key_frames/motion_vectors and datasets video

    [ frame_indexes, query_keyframes_org ] = retrieve_video( video_query_features, pca_mapping, itq_rot_mat, hash_table, min_change,retrieve_by_motion ); 
    [ per_video ] = retrival_by_video_index( frame_indexes,mapped  );
    
    history_frames=query_keyframes_org;
    while size(per_video,1)<max_return
        tt= randi([1 size(query_keyframes_org,1)],1,ceil(size(query_keyframes_org,1)/3));
        query_keyframes = query_keyframes_org(tt,:);
        
        frm_idx =1;
        while frm_idx<=size(query_keyframes,1)
            bin_val = de2bi(query_keyframes(frm_idx,2),size(pca_mapping,2),'left-msb');
            while size(find(history_frames(:,2)==bi2de(bin_val,'left-msb')),1)>0
                candidate_bit = randi([1 size(pca_mapping,2)]);
                bin_val(candidate_bit) = not(bin_val(candidate_bit));
            end        
            query_keyframes(frm_idx,2) = bi2de(bin_val,'left-msb');
            history_frames = [history_frames; query_keyframes(frm_idx,:)];
            frm_idx=frm_idx+1;
        end
        [ frame_indexes, query_keyframes ] = retrieve_video( video_query_features, pca_mapping, itq_rot_mat, hash_table, min_change,retrieve_by_motion, query_keyframes ); 
        [ per_video ] = retrival_by_video_index( frame_indexes,mapped, per_video  );
    end
    
    if not(exist('make_unique','var'))
        make_unique = true;
    end
    
    [ per_video , ranked_list ] = sort_cells_by_col( per_video, 2 ,make_unique); 
    per_video(:,5)=num2cell(ranked_list);
    
end

