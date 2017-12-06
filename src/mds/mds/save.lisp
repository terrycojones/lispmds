(in-package user)

;;;----------------------------------------------------------------------
;;;                      save configuration
;;;----------------------------------------------------------------------

(defun write-save-form (save-form filename &optional &key (if-exists :supersede))
;;(save-form filename (if (member (user-name) '("stefan") (if-exists :supersede))(if-exists :overwrite))) ;;this doesn't work..
						     
							     
  (with-open-file (out filename :direction :output 
		   :if-exists if-exists
		   :if-does-not-exist :create)
    
    
    (format out 
	    ;;";; MDS configuration file (version 0.0).~%;; Created for ~a at ~a~%~%" 
	    ;;";; MDS configuration file (version 0.1).~%;; Created for ~a at ~a~%~%"   v0.1 for ag-sr tables store as un-as table, saves 20x space 2002-02-08
	    ;;";; MDS configuration file (version 0.2).~%;; Created for ~a at ~a~%~%"   v0.2 put all the table sets into a function, saves 3x space 2002-02-11
	    ;;";; MDS configuration file (version 0.3).~%;; Created for ~a at ~a~%~%"  ;; v0.3 write many params in plot spec making mods easier 2002-02-12
	    ;;";; MDS configuration file (version 0.4).~%;; Created for ~a at ~a~%~%"  ;; v0.4 write shape in plot spec 2002-07-10
	    ;;";; MDS configuration file (version 0.5).~%;; Created for ~a at ~a~%~%"    ;; v0.5 write with print, not format ~s for memory space reasons 2004-09-05
            ";; MDS configuration file (version 0.6).~%;; Created for ~a at ~a~%~%"    ;; v0.6 Add :raise-points and lower-points 2006-10-13
	    ;; note, the above line is also in output-table-extract above, if we change it here, change it there and vice-versa.
	    (hi-table-name-table-from-save-non-expanding-hack save-form)
	    (time-and-date))
    ;; (format out "~s" save-form)  ;;for all of the cdc merge (~2700 strainsx40 ags, was taking >900M and size limit on max os, which i could not get around
    (print save-form out)           ;;also, the print takes a few seconds, whereas the format was taking a while before it crashed
    save-form))                     ;;not sure if we need the ~s, and whether print does it.  derek 2004-09-05
  

(defun save-configuration-from-mds-window (mds-window filename &optional &key change-to-num-dimensions)
  (save-configuration (get-table-window-for-mds-window mds-window)
		      filename
		      :starting-coordss             (get-mds-coordss mds-window)
		      :canvas-coord-transformations (get-canvas-coord-transformations mds-window)
		      :procrustes-data              (get-procrustes-data mds-window)
                      :raise-points                 (get-raise-points mds-window)
                      :lower-points                 (get-lower-points mds-window)
                      :change-to-num-dimensions     change-to-num-dimensions))


(defun save-configuration (table-window filename &key
                                                 starting-coordss
                                                 canvas-coord-transformations
                                                 procrustes-data
                                                 raise-points
                                                 lower-points
                                                 change-to-num-dimensions)
  (let ((save (apply #'make-save-form 
                     :hi-table (get-hi-table table-window)
                     :pre-merge-tables (get-pre-merge-tables table-window)
                     :starting-coordss (if starting-coordss  ;; so that when we save from batch-input-ui, starting
                                           starting-coordss  ;; coordss are set also.
                                         (nth 0 (nth 0 (get-batch-runs-data table-window))))
                     :batch-runs (get-batch-runs-data table-window)
                     :mds-dimensions (get-mds-num-dimensions table-window)
                     :coords-colors (get-coords-colors table-window)
                     :coords-outline-colors (get-coords-outline-colors table-window)
                     :coords-dot-sizes (get-coords-dot-sizes table-window)
                     :coords-transparencies (get-coords-transparencies table-window)
                     :coords-names (get-coords-names table-window)
                     :coords-names-working-copy (get-coords-names-working-copy table-window)
                     :coords-name-sizes (get-coords-name-sizes table-window)
                     :coords-name-colors (get-coords-name-colors table-window)
                     :coords-shapes (get-coords-shapes table-window)
                     :moveable-coords (get-moveable-coords table-window)
                     :unmoveable-coords (get-unmoveable-coords table-window)
                     :canvas-coord-transformations (if canvas-coord-transformations

                                                       canvas-coord-transformations
                                                     (get-canvas-coord-transformations table-window))
                     :constant-stress-radial-data (get-constant-stress-radial-data table-window)
                     :reference-antigens (get-reference-antigens table-window)
                     :procrustes-data procrustes-data
                     :raise-points (if raise-points raise-points (get-raise-points table-window))
                     :lower-points (if lower-points lower-points (get-lower-points table-window))
                     :acmacs-a1-antigens (get-acmacs-a1-antigens table-window)
                     :acmacs-a1-sera     (get-acmacs-a1-sera     table-window)
                     :acmacs-b1-antigens (get-acmacs-b1-antigens table-window)
                     :acmacs-b1-sera     (get-acmacs-b1-sera     table-window)
                     :date                   (get-date                   table-window)
                     :rbc-species            (get-rbc-species            table-window)
                     :lab                    (get-lab                    table-window)
                     :minimum-column-basis   (get-minimum-column-basis   table-window)
                     :allow-titers-less-than (get-allow-titers-less-than table-window)
                     :titer-type             (get-titer-type             table-window)
                     (let ((hi-table (get-hi-table table-window))
                           (hi-table-working-copy (get-hi-table-working-copy table-window)))
                       (if (not (equal hi-table hi-table-working-copy))
                           `(:hi-table-working-copy ,(make-in-form
                                                      (make-hi-table 
                                                       (hi-table-antigens hi-table)
                                                       (hi-table-sera     hi-table)
                                                       (hi-table-values   hi-table-working-copy)
                                                       (glue-up (list (hi-table-name hi-table) 'wc) '-))))
                         nil)))))
    (write-save-form
     (if (numberp change-to-num-dimensions)
         (set-save-keyword-entry 
          (remove-save-keyword-entries
           save
           '(:starting-coordss :batch-runs :canvas-coord-transformations :constant-stress-radial-data :procrustes-data)
           :not-found-action :ignore)
          :mds-dimensions change-to-num-dimensions
          :not-found-action :add)
       save)
     filename)))


(defun dont-care-to-* (hi-table-values)
  (loop for row in hi-table-values collect
	(loop for e in row collect
	      (if (eql 'dont-care e)
		  '*
		e))))

(defun *-to-dont-care (hi-table-values)
  (loop for row in hi-table-values collect
	(loop for e in row collect
	      (if (eql '* e)
		  'dont-care
		e))))

(defun hi-in (antigens sera values name)
  (setq last-hi-table
    (set name
      (make-ag-sr-hi-table
       (make-hi-table
	antigens
	sera
	(*-to-dont-care values)
	name)))))

(defun tab-in (antigens sera values name)
  (setq last-hi-table
    (set name
      (make-hi-table
       antigens
       sera
       (*-to-dont-care values)
       name))))
  
(defun make-in-form (hi-table &optional &key use-tab-in)
  (let* ((ag-sr-table-p (ag-sr-table-p hi-table))
	 (un-as-hi-table (if ag-sr-table-p (un-as-hi-table hi-table)))
	 (hi-table-not-in-ar-sr-form-p (hi-table-not-in-ar-sr-form-p hi-table)))
    (cond ((and ag-sr-table-p (not use-tab-in))
	   `(hi-in 
	     ',(hi-table-antigens un-as-hi-table)
	     ',(hi-table-sera     un-as-hi-table)
	     ',(dont-care-to-* (hi-table-values   un-as-hi-table))
	     ',(hi-table-name     un-as-hi-table)))
	  ((and hi-table-not-in-ar-sr-form-p (not use-tab-in))
	   `(hi-in 
	     ',(hi-table-antigens hi-table)
	     ',(hi-table-sera     hi-table)
	     ',(dont-care-to-* (hi-table-values (f-hi-table #'std-log-titer hi-table)))
	     ',(hi-table-name     hi-table)))
	  (t 
	   `(tab-in
	     ',(hi-table-antigens hi-table)
	     ',(hi-table-sera     hi-table)
	     ',(dont-care-to-* (hi-table-values   hi-table))
	     ',(hi-table-name     hi-table))))))

(defun make-save-form-p (sexp)
  (and (listp sexp)
       (eql 'make-save-form (car sexp))))

(defun make-save-form (&key hi-table
                            (hi-table-working-copy     'not-passed)
			    (starting-coordss          'not-passed)           ;;  **************** CAREFUL ***************
			    (batch-runs                'not-passed)           ;;  when adding a parameter, also add to the
			    (mds-dimensions            'not-passed)           ;;  2 lists in the body.  this could be a macro
			    (coords-colors             'not-passed)           ;;  but then it would be a bit confusing in a different way
			    (coords-dot-sizes          'not-passed)
                            (coords-transparencies     'not-passed)
			    (coords-names              'not-passed)
			    (coords-names-working-copy 'not-passed)
			    (coords-name-sizes         'not-passed)
			    (coords-name-colors        'not-passed)
			    (coords-shapes             'not-passed)
			    (moveable-coords           'not-passed)
			    (unmoveable-coords         'not-passed)
			    (adjustable-rows           'not-passed)
			    (adjustable-columns        'not-passed)
			    (unmoveable-dimensions     'not-passed)
			    (unmoveable-dimensions-in-second-phase 'not-passed)
			    (dim-anneal-coefficients   'not-passed)
			    ;;show-error-lines    ;; not sure, probably not right now
			    (coords-outline-colors     'not-passed)
			    (plot-spec                 'not-passed)
			    (canvas-coord-transformations 'not-passed)
			    (constant-stress-radial-data  'not-passed)
			    (reference-antigens           'not-passed)
			    reassortments
			    equivalent-row-names
			    equivalent-column-names
			    (procrustes-data            'not-passed)
                            (raise-points               'not-passed)
                            (lower-points               'not-passed)
			    (error-connection-prediction-line-data 'not-passed)
                            (pre-merge-tables           'not-passed)
                            (acmacs-a1-antigens         'not-passed)
                            (acmacs-a1-sera             'not-passed)
                            (acmacs-b1-antigens         'not-passed)
                            (acmacs-b1-sera             'not-passed)
                            ;; the below not sourced by lispmds, but are in saves generated by acmacs and should be maintained when present
                            (date                       'not-passed)
                            (rbc-species                'not-passed)
                            (lab                        'not-passed)
                            (minimum-column-basis       'not-passed)
                            (allow-titers-less-than     'not-passed)
                            (titer-type                 'not-passed)
                            )
  
  ;; ignore these for now
  reassortments
  equivalent-row-names
  equivalent-column-names
  
  `(make-master-mds-window
    ,(make-in-form hi-table)
    ,@(loop for arg-name in '(hi-table-working-copy
                              starting-coordss
			      batch-runs
			      mds-dimensions    ;; check we set
			      ;;coords-colors                now in plot-spec
			      ;;coords-dot-sizes             now in plot-spec
			      ;;coords-names                 now in plot-spec
			      ;;coords-names-working-copy    now in plot-spec
			      ;;coords-name-sizes            now in plot-spec
			      ;;coords-name-colors           now in plot-spec
			      ;;coords-shapes                now in plot-spec
			      moveable-coords
			      unmoveable-coords
			      adjustable-rows
			      adjustable-columns
			      unmoveable-dimensions
			      unmoveable-dimensions-in-second-phase
			      dim-anneal-coefficients
			      ;;show-error-lines    ;; not sure, probably not right now
			      ;;coords-outline-colors        now in plot-spec
			      plot-spec
			      canvas-coord-transformations
			      constant-stress-radial-data
			      reference-antigens
			      procrustes-data
                              raise-points
                              lower-points
			      error-connection-prediction-line-data
                              pre-merge-tables
                              acmacs-a1-antigens
                              acmacs-a1-sera
                              acmacs-b1-antigens
                              acmacs-b1-sera
                              date                  
                              rbc-species           
                              lab                   
                              minimum-column-basis  
                              allow-titers-less-than
                              titer-type            
			      )
	  for arg-value in (list hi-table-working-copy
                                 starting-coordss
				 batch-runs
				 mds-dimensions    ;; check we set
				 ;;coords-colors                now in plot-spec
				 ;;coords-dot-sizes             now in plot-spec
				 ;;coords-names                 now in plot-spec
				 ;;coords-names-working-copy    now in plot-spec
				 ;;coords-name-sizes            now in plot-spec
				 ;;coords-name-colors           now in plot-spec
				 ;;coords-shapes                now in plot-spec
				 moveable-coords
				 unmoveable-coords
				 adjustable-rows
				 adjustable-columns
				 unmoveable-dimensions
				 unmoveable-dimensions-in-second-phase
				 dim-anneal-coefficients
				 ;;show-error-lines    ;; not sure, probably not right now
				 ;;coords-outline-colors        now in plot-spec
				 plot-spec
				 canvas-coord-transformations
				 constant-stress-radial-data
				 reference-antigens
				 procrustes-data
                                 raise-points
                                 lower-points
				 error-connection-prediction-line-data
                                 pre-merge-tables
                                 acmacs-a1-antigens
                                 acmacs-a1-sera
                                 acmacs-b1-antigens
                                 acmacs-b1-sera
                                 date                  
                                 rbc-species           
                                 lab                   
                                 minimum-column-basis  
                                 allow-titers-less-than
                                 titer-type            
				 )
	  when (not (eql 'not-passed arg-value))
	  append
	    `(,(read-from-string (string-append ":" (string arg-name))) 
              ,(cond ((equal 'hi-table-working-copy arg-name) arg-value)
                     ((equal 'pre-merge-tables arg-name)      `(list ,@(loop for table in arg-value collect
                                                                             (make-in-form table :use-tab-in t))))
                     (t `',arg-value))))
    ,@(if (or (not (eql 'not-passed coords-colors))            
	      (not (eql 'not-passed coords-dot-sizes))         
              (not (eql 'not-passed coords-transparencies))            
	      (not (eql 'not-passed coords-names))             
	      (not (eql 'not-passed coords-names-working-copy))
	      (not (eql 'not-passed coords-name-sizes))        
	      (not (eql 'not-passed coords-name-colors))       
	      (not (eql 'not-passed coords-outline-colors))
	      (not (eql 'not-passed coords-shapes)))
	  (progn
	    (if (not (eql 'not-passed plot-spec))
		(error "Internal inconsistency.  Do not supply both plot-spec and coords-plot-spec details to make-save-form"))
	    `(:plot-spec
	      ',(generate-plot-spec 
		 (hi-table-antigens hi-table)
		 :coords-colors             (if (eql 'not-passed coords-colors)             nil coords-colors)
		 :coords-dot-sizes          (if (eql 'not-passed coords-dot-sizes)          nil coords-dot-sizes)
		 :coords-transparencies     (if (eql 'not-passed coords-transparencies)     nil coords-transparencies)
		 :coords-names              (if (eql 'not-passed coords-names)              nil coords-names)
		 :coords-names-working-copy (if (eql 'not-passed coords-names-working-copy) nil coords-names-working-copy)
		 :coords-name-sizes         (if (eql 'not-passed coords-name-sizes)         nil coords-name-sizes)
		 :coords-name-colors        (if (eql 'not-passed coords-name-colors)        nil coords-name-colors)
		 :coords-outline-colors     (if (eql 'not-passed coords-outline-colors)     nil coords-outline-colors)
		 :coords-shapes             (if (eql 'not-passed coords-shapes)             nil coords-shapes)
		 ))))))


(defun subset-save-form (save-form ag-and-sr-names &optional &key include-all-antigens include-all-sera)
  (let ((table (table-from-save save-form)))
    (if include-all-antigens (setq ag-and-sr-names (my-union (hi-table-antigens-short table) ag-and-sr-names)))
    (if include-all-sera     (setq ag-and-sr-names (my-union ag-and-sr-names (hi-table-sera-short     table))))
    (let ((starting-coordss (starting-coords-from-save save-form))
          (batch-runs (batch-runs-from-save save-form))
          (canvas-coord-transformations (canvas-coord-transformations-from-save save-form))
          (plot-spec (plot-spec-from-save save-form))
          (reference-antigens (reference-antigens-from-save save-form))
          (raise-points       (raise-points-from-save       save-form))
          (lower-points       (lower-points-from-save       save-form)))
      (let* ((table-extract (extract-hi-table table ag-and-sr-names ag-and-sr-names))
             (pre-merge-table-extracts (filter #'null  ;; remove table that have become empty
                                               (loop for pre-merge-table in (pre-merge-tables-from-save save-form) collect
                                                     (extract-hi-table 
                                                      pre-merge-table 
                                                      (my-intersection (hi-table-antigens pre-merge-table) (mapcar #'remove-ag-sr-from-name (collect #'ag-name-p ag-and-sr-names)))
                                                      (my-intersection (hi-table-antisera pre-merge-table) (mapcar #'remove-ag-sr-from-name (collect #'sr-name-p ag-and-sr-names)))))))
             (coordss-extract (if starting-coordss (subset-coordss starting-coordss table table-extract)))
             (batch-runs-extract (loop for (coordss stress unused1 unused2) in batch-runs 
                                     when (not (equal stress "Queued"))
                                     collect
                                       (list (subset-coordss coordss table table-extract)
                                             stress unused1 unused2)))
             (plot-spec-subset (if plot-spec (plot-spec-subset plot-spec ag-and-sr-names)))
             (reference-antigens-subset (if reference-antigens 
                                            (my-intersection reference-antigens (mapcar #'remove-ag-sr-from-name (collect #'ag-name-p ag-and-sr-names)))))
             (raise-points-subset (if raise-points (my-intersection raise-points ag-and-sr-names)))
             (lower-points-subset (if lower-points (my-intersection lower-points ag-and-sr-names)))

             (save-all-ags (collect #'ag-name-p (hi-table-antigens table)))
             (save-all-sr  (collect #'sr-name-p (hi-table-antigens table)))

             (ag-positions (loop for name in ag-and-sr-names 
                               when (ag-name-p name)
                               collect (position name save-all-ags)))

             (sr-positions (loop for name in ag-and-sr-names 
                               when (sr-name-p name)
                               collect (position name save-all-sr)))

             (acmacs-b1-antigens-subset (multiple-nth ag-positions (acmacs-b1-antigens-from-save save-form)))
             (acmacs-b1-sera-subset     (multiple-nth sr-positions (acmacs-b1-sera-from-save     save-form)))
             )
        (apply #'make-save-form 
               :hi-table table-extract
               (append (if pre-merge-table-extracts (list :pre-merge-tables pre-merge-table-extracts))
                       (if coordss-extract (list :starting-coordss coordss-extract))
                       (if batch-runs-extract (list :batch-runs batch-runs-extract))
                       (if plot-spec-subset (list :plot-spec plot-spec-subset))
                       (if canvas-coord-transformations (list :canvas-coord-transformations canvas-coord-transformations))
                       (if reference-antigens-subset (list :reference-antigens reference-antigens-subset))
                       (if raise-points-subset       (list :raise-points       raise-points))
                       (if lower-points-subset       (list :lower-points       lower-points))
                       (if acmacs-b1-antigens-subset (list :acmacs-b1-antigens acmacs-b1-antigens-subset))
                       (if acmacs-b1-sera-subset     (list :acmacs-b1-sera     acmacs-b1-sera-subset)))
               ;; these would be good to extract from the same, but not implemented yet (2002-06-07)
               ;;:mds-dimensions (get-mds-num-dimensions table-window)
               ;;:coords-colors (multiple-nth point-indices (get-coords-colors table-window))
               ;;:coords-dot-sizes (multiple-nth point-indices (get-coords-dot-sizes table-window))
               ;;:coords-names (multiple-nth point-indices (get-coords-names table-window))
               ;;:coords-names-working-copy (multiple-nth point-indices (get-coords-names-working-copy table-window))
               ;;:coords-name-sizes (multiple-nth point-indices (get-coords-name-sizes table-window))
               ;;:coords-name-colors (multiple-nth point-indices (get-coords-name-colors table-window))

               ;; these two do not work, maybe not because of this, but maybe passing these in
               ;;   to make-master-mds-window does not work (at lease we don't get the colors in tk
               ;;   and we seem to get movement when we optimize
               ;;:moveable-coords (let ((moveable-coords (get-moveable-coords table-window)))
               ;;		  (if (eql 'all moveable-coords)
               ;;		      moveable-coords
               ;;		    (reverse (intersection moveable-coords point-indices))))
               ;;:unmoveable-coords (reverse (intersection (get-unmoveable-coords table-window) point-indices))
               )))))

(defun subset-save-form-by-excluding (save-form ag-and-sr-names)
  (subset-save-form
   save-form
   (reverse (set-difference (hi-table-antigens (table-from-save save-form)) ag-and-sr-names))))

(defun remove-duplicates-from-save (save)
  (let ((strains (hi-table-antigens (table-from-save save))))
    (subset-save-form
     save
     (remove-duplicates strains))))     

#||
;; replace with the below, aug 2004, derek, to use the new merge code
(defun extend-save-form-with-table (save-form extending-table
				    &optional &key 
					      (new-coords '(0 0))
					      ;;(new-color  'black)
					      )
  (let* ((table-from-save 
	  (table-from-save save-form))
	 (merged-table 
	  (hi-table-to-asl
	   (hi-table-lt10titer-to-lt10s
	    (merge-table-tables-new-new-new-new
	     :tables-to-include (list
				 (un-asl-hi-table table-from-save)
				 (un-asl-hi-table extending-table))
	     :all-strains-from-tables t))))
	 (save-form-subset (subset-save-form
			    save-form
			    (my-intersection 
			     (hi-table-antigens table-from-save)
			     (hi-table-antigens merged-table))))
	 (new-starting-coordss
	  (let ((save-form-subset-starting-coordss (starting-coordss-from-save save-form-subset))
		(save-form-subset-names (hi-table-antigens (table-from-save save-form-subset)))
		(new-more (nth-value 
			   1
			   (deconstruct-coordss-plus-more
			    (make-random-coordss 
			     (hi-table-length merged-table) 
			     (get-save-keyword-entry save-form :mds-dimensions)
			     (hi-table-max-value merged-table)
			     (similarity-table-p merged-table)
			     merged-table)))))
	    (reconstruct-coordss-plus-more
	     (loop for name in (hi-table-antigens merged-table) collect
		   (if (member name save-form-subset-names)
		       (nth (position name save-form-subset-names) save-form-subset-starting-coordss)
		     new-coords))
	     new-more))))
    (make-save-form
     :hi-table merged-table
     :starting-coordss new-starting-coordss
     :plot-spec (plot-spec-from-save save-form-subset))))
||#

(defun extend-save-form-with-table (save-form extending-table
				    &optional &key 
					      (new-coords '(0 0))
					      (new-points-color "black")
					      (new-points-size  6)
					      (merge-diagnostics-filename "tmp/merge-diagnostics")
                                              (remerge-from-original-tables t)
					      (if-exists-action :error))
  (format t "~2%Warning: Not carrying forward any row or col adjusts.~%")
  ;; We could carry any row or col adjusts, but there is a tricky thing, the col basis might change because
  ;; of the introduction of a new ag, what to do then.  For now, just do the simple thing and reset.
  (let* ((table-from-save 
	  (table-from-save save-form))
         (tables-to-merge
          (append
           (if (and remerge-from-original-tables (pre-merge-tables-from-save save-form))
               (pre-merge-tables-from-save save-form)
             (list (un-asl-hi-table table-from-save)))
           (list (un-asl-hi-table extending-table))))
	 (merged-table 
	  (table-from-save 
	   (merge-tables tables-to-merge
                         :sort-hi-table-names nil
			 :filename merge-diagnostics-filename
			 :if-exists-action if-exists-action)))
	 (save-form-subset (subset-save-form
			    save-form
			    (my-intersection 
			     (hi-table-antigens table-from-save)
			     (hi-table-antigens merged-table))))
	 (save-form-subset-names (hi-table-antigens (table-from-save save-form-subset)))
	 (new-starting-coordss
	  (let* ((save-form-subset-starting-coordss (starting-coordss-from-save save-form-subset))
		 (new-more (nth-value 
			    1
			    (deconstruct-coordss-plus-more
			     (make-random-coordss 
			      (hi-table-length merged-table) 
			      ;;(get-save-keyword-entry save-form :mds-dimensions)
			      (length (car (coordss save-form-subset-starting-coordss)))
			      (hi-table-max-value merged-table)
			      (similarity-table-p merged-table)
			      merged-table)))))
	    (reconstruct-coordss-plus-more
	     (loop for name in (hi-table-antigens merged-table) collect
		   (if (member name save-form-subset-names)
		       (nth (position name save-form-subset-names) save-form-subset-starting-coordss)
		     new-coords))
	     new-more)))
	 (original-plot-spec (plot-spec-from-save save-form))
	 (new-plot-spec
	  (loop for name in (hi-table-antigens merged-table) collect
		(if (member name save-form-subset-names)
		    (assoc name original-plot-spec)
		  `(,name :ds ,new-points-size :co ,new-points-color)))))
    (make-save-form
     :hi-table merged-table
     :starting-coordss new-starting-coordss
     :pre-merge-tables tables-to-merge
     :plot-spec new-plot-spec)))


;;;----------------------------------------------------------------------
;;;              programatic extracting from a save
;;;----------------------------------------------------------------------

;; superseded by the better name below, this kept for backwards compatability
(defun extract-table-from-save (save)
  (table-from-save save))

(defun table-from-save (save)
  (eval (nth 1 save)))

(defun extract-best-coordss-from-save-or-starting-coords-if-no-batch-runs (save)
  (best-coordss-from-save-or-starting-coords-if-no-batch-runs save))

(defun best-coordss-from-save-or-starting-coords-if-no-batch-runs (save)
  (let ((batch-runs (eval (snoop-keyword-arg :batch-runs (cddr save) 
					     :not-found-action :return-nil)))
	(starting-coordss (eval (snoop-keyword-arg :starting-coordss (cddr save)
						   :not-found-action :return-nil))))
    (if batch-runs
	(nth 0 (nth 0 batch-runs))
      starting-coordss)))

(defun starting-coordss-from-save (save)
  (eval (snoop-keyword-arg :starting-coordss (cddr save)
			   :not-found-action :return-nil)))

(defun starting-coords-from-save (save) (starting-coordss-from-save save))

(defun starting-coordss-or-best-batch-from-save (save)
  (let ((starting-coordss (eval (snoop-keyword-arg :starting-coordss (cddr save)
						   :not-found-action :return-nil))))
    (if starting-coordss
	starting-coordss
      (nth 0 (nth 0 (batch-runs-from-save save))))))

(defun starting-mds-coordss-coordss-from-save (save)
  (mds-to-canvas-coordss-given-canvas-coord-transformations
   (canvas-coord-transformations-from-save save)
   (coordss (starting-coords-from-save save))))

(defun starting-mds-coordss-coordss-no-scale-from-save (save)
  (mds-to-canvas-coordss-given-canvas-coord-transformations-no-scale
   (canvas-coord-transformations-from-save save)
   (coordss (starting-coords-from-save save))))

(defun starting-mds-coordss-coordss-bottom-y-from-save (save)
  (mds-to-canvas-coordss-given-canvas-coord-transformations
   (flip-bottom-y-to-top-y-in-canvas-coord-transformations
    (canvas-coord-transformations-from-save save))
   (coordss (starting-coords-from-save save))))

(defun starting-mds-coordss-coordss-no-scale-flip-y-from-save (save)
  (mds-to-canvas-coordss-given-canvas-coord-transformations-no-scale
   (flip-y-in-canvas-coord-transformations
    (canvas-coord-transformations-from-save save))
   (coordss (starting-coords-from-save save))))



(defun batch-runs-from-save (save)
  (eval (snoop-keyword-arg :batch-runs (cddr save)
			   :not-found-action :return-nil)))

(defun batch-run-stresses-from-save (save)
  (nths 1 (batch-runs-from-save save)))

(defun starting-coords-stress-from-save (save)
  (if (not (equal (nth-best-coords-from-save save 0)
                  (starting-coords-from-save save)))
      (progn
        (print "Warning: Usual case is that the lowest stress run is the starting coords, but is not the case in this case.  The starting coords do not have to be the best batch run, it is just that this function, to get the starting coords stress from a save picks up the stresses from the batch coords stresses (the only ones that are stored).  It could be that there are no batch runs, or that the starting coords are different from the best batch run.  At some point we should store the stress with the starting coords.")
        'not-available)
    (nth 0 (batch-run-stresses-from-save save))))

(defun nth-best-coords-from-save (save n)
  (nth 0 (nth n (batch-runs-from-save save))))

(defun plot-spec-from-save (save)
  (eval (snoop-keyword-arg :plot-spec (cddr save)
			   :not-found-action :return-nil)))

(defun remove-plot-spec-from-save (save)
  (remove-save-keyword-entry save :plot-spec :not-found-action :ignore))

(defun constant-stress-radial-data-from-save (save)
  (eval (snoop-keyword-arg :constant-stress-radial-data (cddr save)
			   :not-found-action :return-nil)))

(defun antigens-from-save (save)
  (hi-table-antigens (table-from-save save)))

(defun reference-antigens-from-save (save)
  (eval (snoop-keyword-arg :reference-antigens (cddr save)
			   :not-found-action :return-nil)))

(defun num-dimensions-from-save (save)
  (eval (snoop-keyword-arg :mds-dimensions (cddr save)
			   :not-found-action :return-nil)))

(defun procrustes-data-from-save (save)
  (eval (snoop-keyword-arg :procrustes-data (cddr save)
			   :not-found-action :return-nil)))

(defun raise-points-from-save (save)
  (eval (snoop-keyword-arg :raise-points (cddr save)
			   :not-found-action :return-nil)))

(defun lower-points-from-save (save)
  (eval (snoop-keyword-arg :lower-points (cddr save)
			   :not-found-action :return-nil)))

(defun error-connection-prediction-line-data-from-save (save)
  (eval (snoop-keyword-arg :error-connection-prediction-line-data (cddr save)
			   :not-found-action :return-nil)))

(defun landscape-titers-from-save (save)
  (eval (snoop-keyword-arg :landscape-titers (cddr save)
			   :not-found-action :return-nil)))

(defun mds-dimensions-from-save (save)
  (eval (snoop-keyword-arg :mds-dimensions (cddr save)
			   :not-found-action :return-nil)))

(defun test-antigens-from-save (save)
  (let ((reference-antigens (reference-antigens-from-save save)))
    (my-set-difference (hi-table-antigens (un-asl-hi-table (table-from-save save))) reference-antigens)))

(defun set-reference-antigens-in-save (save reference-antigens &optional &key (not-found-action :error))
  (set-save-keyword-entry save :reference-antigens reference-antigens :not-found-action not-found-action))

(defun set-raise-points-in-save (save raise-points &optional &key (not-found-action :error))
  (set-save-keyword-entry save :raise-points raise-points :not-found-action not-found-action))

(defun set-lower-points-in-save (save lower-points &optional &key (not-found-action :error))
  (set-save-keyword-entry save :lower-points lower-points :not-found-action not-found-action))

(defun append-to-raise-points-in-save (save additional-raise-points &optional &key (not-found-action :error))
  (let ((existing-raise-points (raise-points-from-save save)))
    (set-save-keyword-entry save 
                            :raise-points (my-union existing-raise-points additional-raise-points)
                            :not-found-action not-found-action)))

(defun append-to-lower-points-in-save (save additional-lower-points &optional &key (not-found-action :error))
  (let ((existing-lower-points (lower-points-from-save save)))
    (set-save-keyword-entry save 
                            :lower-points (my-union existing-lower-points additional-lower-points)
                            :not-found-action not-found-action)))

(defun canvas-coord-transformations-from-save (save)
  (eval (snoop-keyword-arg :canvas-coord-transformations (cddr save)
			   :not-found-action :return-nil)))

(defun canvas-basis-vectors-from-save (save)
  (let* ((canvas-coord-transformations (canvas-coord-transformations-from-save save))
         (basis-vectors (list
                         (snoop-keyword-arg :canvas-basis-vector-0 canvas-coord-transformations :not-found-action :return-nil)
                         (snoop-keyword-arg :canvas-basis-vector-1 canvas-coord-transformations :not-found-action :return-nil))))
    (if (equal (list nil nil) basis-vectors)
        (progn
          (print "Warning: basis vectors not available in save, likely as this save has not been saves from the gui, or oriented programatically")
          'not-available)
      basis-vectors)))

(defun canvas-coord-scale-from-save (save)
  (let* ((canvas-coord-transformations (canvas-coord-transformations-from-save save))
         (coord-scale (list
                         (snoop-keyword-arg :canvas-x-coord-scale canvas-coord-transformations :not-found-action :return-nil)
                         (snoop-keyword-arg :canvas-y-coord-scale canvas-coord-transformations :not-found-action :return-nil))))
    (if (equal (list nil nil) coord-scale)
        (progn
          (print "Warning: coord scale not available in save, likely as this save has not been saves from the gui, or oriented programatically")
          'not-available)
      coord-scale)))

(defun basis-vector-point-indices-from-save (save)
  (let* ((canvas-coord-transformations (canvas-coord-transformations-from-save save))
		 (basis-vector-point-indices (snoop-keyword-arg :basis-vector-point-indices canvas-coord-transformations :not-found-action :return-nil)))
    (if (equal nil basis-vector-point-indices)
		'not-available
		(list basis-vector-point-indices))))

(defun coords-colors-from-save (save)
  (let* ((coords-colors-by-get-keyword (get-save-keyword-entry save :coords-colors :not-found-action :return-nil))
	 (plot-spec (plot-spec-from-save save))
	 (plot-spec-names (nths 0 plot-spec))
	 (table-names (hi-table-antigens (table-from-save save))))
    (if coords-colors-by-get-keyword
	coords-colors-by-get-keyword
      (progn
	(if (not (equal plot-spec-names table-names))
	    (error "need to take the care to match up names in plot spec with order of names in table"))
	(loop for line in plot-spec collect
	      (let ((color (snoop-keyword-arg :co line :not-found-action :return-nil)))
		(if (not color)
		    "#0000ff"
		  color)))))))

(defun coords-name-colors-from-save (save)
  (let* ((coords-name-colors-by-get-keyword (get-save-keyword-entry save :coords-name-colors :not-found-action :return-nil))
	 (plot-spec (plot-spec-from-save save))
	 (plot-spec-names (nths 0 plot-spec))
	 (table-names (hi-table-antigens (table-from-save save))))
    (if coords-name-colors-by-get-keyword
	coords-name-colors-by-get-keyword
      (progn
	(if (not (equal plot-spec-names table-names))
	    (error "need to take the care to match up names in plot spec with order of names in table"))
	(loop for line in plot-spec collect
	      (let ((name-color (snoop-keyword-arg :nc line :not-found-action :return-nil)))
		(if (not name-color)
		    "black"
		  name-color)))))))

(defun coords-dot-sizes-from-save (save)
  (let* ((coords-dot-sizes-by-get-keyword (get-save-keyword-entry save :coords-dot-sizes :not-found-action :return-nil))
	 (plot-spec (plot-spec-from-save save))
	 (plot-spec-names (nths 0 plot-spec))
	 (table-names (hi-table-antigens (table-from-save save))))
    (if coords-dot-sizes-by-get-keyword
	coords-dot-sizes-by-get-keyword
      (progn
	(if (not (equal plot-spec-names table-names))
	    (error "need to take the care to match up names in plot spec with order of names in table"))
	(loop for line in plot-spec collect
	      (let ((dot-size (snoop-keyword-arg :ds line :not-found-action :return-nil)))
		(if (not dot-size)
		    4
		  dot-size)))))))

(defun coords-transparencies-from-save (save)
  (let* ((coords-transparencies-by-get-keyword (get-save-keyword-entry save :coords-transparencies :not-found-action :return-nil))
	 (plot-spec (plot-spec-from-save save))
	 (plot-spec-names (nths 0 plot-spec))
	 (table-names (hi-table-antigens (table-from-save save))))
    (if coords-transparencies-by-get-keyword
	coords-transparencies-by-get-keyword
      (progn
	(if (not (equal plot-spec-names table-names))
	    (error "need to take the care to match up names in plot spec with order of names in table"))
	(loop for line in plot-spec collect
	      (let ((transparency (snoop-keyword-arg :tr line :not-found-action :return-nil)))
		(if (not transparency)
		    0.0
		  transparency)))))))

(defun coords-names-working-copy-from-save (save)
  (let* ((coords-names-working-copy-by-get-keyword (get-save-keyword-entry save :coords-names-working-copy :not-found-action :return-nil))
	 (plot-spec (plot-spec-from-save save))
	 (plot-spec-names (nths 0 plot-spec))
	 (table-names (hi-table-antigens (table-from-save save))))
    (if coords-names-working-copy-by-get-keyword
	coords-names-working-copy-by-get-keyword
      (progn
	(if (not (equal plot-spec-names table-names))
	    (error "need to take the care to match up names in plot spec with order of names in table"))
	(loop for line in plot-spec collect
	      (let ((working-name (snoop-keyword-arg :wn line :not-found-action :return-nil)))
		(if (not working-name)
		    ""
		  working-name)))))))

(defun coords-shapes-from-save (save)
  (let* ((coords-shapes-by-get-keyword (get-save-keyword-entry save :coords-shapes :not-found-action :return-nil))
	 (plot-spec (plot-spec-from-save save))
	 (plot-spec-names (nths 0 plot-spec))
	 (table-names (hi-table-antigens (table-from-save save))))
    (if coords-shapes-by-get-keyword
	coords-shapes-by-get-keyword
      (progn
	(if (not (equal plot-spec-names table-names))
	    (error "need to take the care to match up names in plot spec with order of names in table"))
	(loop for line in plot-spec collect
	      (let ((shape (snoop-keyword-arg :sh line :not-found-action :return-nil)))
		(if (not shape)
		    "CIRCLE"
		  shape)))))))

(defun set-plot-spec-keyword-values-in-save (save keyword value names)
  (set-plot-spec-in-save
   save
   (let ((plot-spec (plot-spec-from-save save)))
     (if (not plot-spec)
	 (setq plot-spec (generate-plot-spec (hi-table-antigens (table-from-save save)))))
     (set-plot-spec-keyword-values-in-plot-spec plot-spec keyword value names))
   :not-found-action :add))
#|
(setq t7-save (fi-in "mds/investigations/merge-hi-tables/seq-t7.save"))
(eval (blank-save (set-plot-spec-keyword-values-in-save t7-save :ds 3 'all)))
(eval (blank-save (set-plot-spec-keyword-values-in-save t7-save :ds 3 '(hk/1/68-ag))))
|#


(defun set-plot-spec-keyword-values-in-plot-spec (plot-spec keyword value names)
  (loop for line in plot-spec collect
	(if (or (eql names 'all) 
		(member (car line) names))
	    (subst-keyword-arg keyword line value :not-found-action :add)
	  line)))


(defun coords-from-save (save name)
  (let ((position (position name (hi-table-antigens-table-from-save-non-expanding-hack save))))
    (if position
	(nth position (coordss (starting-coordss-from-save save)))
      nil)))

(defun column-basis-from-save (save name)
  (let ((position (position name (hi-table-antigens (table-from-save save)))))
    (if position
	(nth position (col-bases (starting-coordss-from-save save)))
      nil)))

(defun multiple-coords-from-save (save names)
  (let ((antigens (hi-table-antigens (table-from-save save)))
	(coordss (coordss (starting-coordss-from-save save))))
    (loop for name in names collect
	  (nth (position name antigens) coordss))))

(defun mds-coords-from-save (save name)
  (let ((position (position name (hi-table-antigens (table-from-save save)))))
    (if position
	(nth position (coordss (starting-mds-coordss-coordss-no-scale-from-save save)))
      nil)))

(defun multiple-mds-coords-from-save (save names)
  ;; same as above, but thru the canvas coords transformations (so we also only get 2D out no matter how many D in)
  (let ((antigens (hi-table-antigens (table-from-save save)))
	(coordss (coordss (starting-mds-coordss-coordss-no-scale-from-save save))))
    (loop for name in names collect
	  (nth (position name antigens) coordss))))

(defun dist-between-points-in-save (save p1 p2)
  (let ((p1-coords (coords-from-save save p1))
	(p2-coords (coords-from-save save p2)))
    (e-dist p1-coords p2-coords)))

(defun dist-between-point-in-save-and-coords (save p1 coords)
  (let ((p1-coords (coords-from-save save p1)))
    (e-dist p1-coords coords)))


(defun write-pre-merge-tables-from-save (save directory-for-results)
  (if (not (file-or-directory-exists-p directory-for-results))
      (run-shell-command (format nil "mkdir ~a" directory-for-results) :wait t))
  (loop for table in (pre-merge-tables-from-save save) collect
        (pp-hi-table table 'full-and-short 4 nil :filename (format nil "~a/~a.txt" directory-for-results (hi-table-name table)) :if-exists-action :error)))


;; ------------------------- generic getting/setting values in save form ----------------------

(defun get-save-keyword-entry (save keyword &optional &key (not-found-action :error))
  (eval (snoop-keyword-arg keyword (nthcdr 2 save) :not-found-action not-found-action)))

(defun set-save-keyword-entry (save keyword new-arg &optional &key (not-found-action :error))
  (append (firstn 2 save)
	  (subst-keyword-arg keyword (nthcdr 2 save) `',new-arg :not-found-action not-found-action)))

(defun remove-save-keyword-entry (save keyword &optional &key (not-found-action :error))
  (append (firstn 2 save)
	  (remove-keyword-and-arg keyword (nthcdr 2 save) :not-found-action not-found-action)))

(defun remove-save-keyword-entries (save keywords &optional &key (not-found-action :error))
  (if (null keywords)
      save
    (remove-save-keyword-entries
     (remove-save-keyword-entry save (car keywords) :not-found-action not-found-action)
     (cdr keywords)
     :not-found-action not-found-action)))

(defun set-save-keyword-entry-from-other-save (source-save destination-save keyword &optional &key
											      (not-found-in-source-action :error)
											      (not-found-in-destination-action :error))
  (set-save-keyword-entry
   destination-save
   keyword
   (get-save-keyword-entry
    source-save
    keyword
    :not-found-action not-found-in-source-action)
   :not-found-action not-found-in-destination-action))

;; ------------------------------ adding to save form -------------------------------

(defun set-table-in-save (save table)
  ;; we have to special case the table (not a keyword arg).  should have been!
  `(make-master-mds-window
    ,(make-in-form table)
    ,@(nthcdr 2 save)))

(defun set-table-values-in-save (save values-to-set &optional &key (not-found-action :error))
  (set-table-in-save
   save
   (set-hi-table-values
    (table-from-save save)
    values-to-set
    :not-found-action not-found-action)))

(defun remove-starting-coordss-from-save (save)
  (remove-save-keyword-entry save :starting-coordss :not-found-action :ignore))

(defun remove-batch-runs-from-save (save)
  (remove-save-keyword-entry save :batch-runs :not-found-action :ignore))

(defun remove-starting-coordss-and-batch-runs-from-save (save)
  (remove-starting-coordss-from-save
   (remove-batch-runs-from-save
    save)))

(defun set-batch-runs-in-save (save batch-runs &optional &key (not-found-action :error))
  (set-save-keyword-entry save :batch-runs batch-runs :not-found-action not-found-action))

(defun set-starting-coordss-in-save (save starting-coordss &optional &key (not-found-action :error))
  (set-save-keyword-entry save :starting-coordss starting-coordss :not-found-action not-found-action))

(defun set-starting-coordss-coordss-in-save (save starting-coordss &optional &key (not-found-action :error))
  ;; the coordss part of the extended coordss only
  (let ((existing-coordss-plus-more (starting-coordss-from-save save)))
    (set-save-keyword-entry 
     save 
     :starting-coordss (make-coordss-plus-more 
			starting-coordss
			(col-bases   existing-coordss-plus-more)
			(row-adjusts existing-coordss-plus-more))
   :not-found-action not-found-action)))

(defun set-some-coordss-in-save (save names new-coordss &optional &key allow-names-not-in-save)
  (let* ((antigens (hi-table-antigens-table-from-save-non-expanding-hack save))
	 (positions (loop for name in names collect (position name antigens)))
	 (old-starting-coordss (coordss (starting-coordss-from-save save))))
    (if (null old-starting-coordss)
	(error "save needs starting-coordss set, something is missing"))
    (if (and (member nil positions)
	     (not allow-names-not-in-save))
	(error "All names need to be in the save, but they are not"))
    (let ((new-starting-coordss (copy-list old-starting-coordss)))
      (loop for position in positions
	  for new-coords in new-coordss 
	  when position
	  do
	    (setf (nth position new-starting-coordss) new-coords))
      (set-starting-coordss-coordss-in-save save new-starting-coordss))))

(defun set-some-coordss-by-alist-in-save (save names-coordss-alist &optional &key allow-names-not-in-save)
  (set-some-coordss-in-save save (nths 0 names-coordss-alist) (nths 1 names-coordss-alist) :allow-names-not-in-save allow-names-not-in-save))

(defun set-coordss-in-save-that-intersect-with-other-save (save other-save)
  (set-some-coordss-in-save 
   (orient-slave-save-onto-master-save save other-save)
   (hi-table-antigens (table-from-save other-save))
   (coordss (starting-coordss-from-save other-save))
   :allow-names-not-in-save t))

(defun set-starting-coordss-and-batch-runs-from-batch-runs-in-save (save batch-runs &optional &key (not-found-action :error))
  (if (not (equal batch-runs (sort-batch-runs batch-runs)))
      (error "maybe you should sort the batch runs before you store them in a save?"))
  (set-starting-coordss-in-save
   (set-batch-runs-in-save save batch-runs :not-found-action not-found-action)
   (nth 0 (nth 0 batch-runs))
   :not-found-action not-found-action))

(defun set-best-batch-as-starting-coordss-in-save (save)
  (set-starting-coordss-in-save
   save
   (nth 0 (nth 0 (batch-runs-from-save save)))
   :not-found-action :add))

(defun set-nth-best-batch-as-starting-coordss-in-save (n save)
  (set-starting-coordss-in-save
   save
   (nth 0 (nth n (batch-runs-from-save save)))
   :not-found-action :add))

(defun set-batch-runs-from-starting-coords-in-save-warning-does-stress-calc (save)
  (set-batch-runs-in-save 
   save
   (list (nth-value 1 (calc-stress-for-starting-coords-in-save save)))
   :not-found-action :add))

(defun set-show-hi-table-numbers-in-save (save parameter-value &optional &key (not-found-action :add))
  (set-save-keyword-entry save :show-hi-table-numbers parameter-value :not-found-action not-found-action))
								     
(defun set-plot-spec-in-save (save plot-spec &optional &key (not-found-action :error))
  (set-save-keyword-entry save :plot-spec plot-spec :not-found-action not-found-action))

(defun set-blank-as-possible-hi-in-save (save)
  (set-save-keyword-entry
   (set-show-hi-table-numbers-in-save save nil)
   :show-hi-table-antigens nil
   :not-found-action :add))
   
(defun blank-save (save) (set-blank-as-possible-hi-in-save save))

(defun blank-working-names-in-save (save)
  (set-plot-spec-in-save
   save
   (let ((plot-spec (plot-spec-from-save save)))
     (if plot-spec
	 (loop for line in plot-spec collect
	       (subst-keyword-arg :wn line "" :not-found-action :add))
       '((default :wn ""))))
   :not-found-action :add))

(defun set-save-colors-to-ag-gray-sr-red (save)
  (set-plot-spec-in-save
   save
   (let ((plot-spec (if (plot-spec-from-save save)
                        (plot-spec-from-save save)
                      (generate-plot-spec (hi-table-antigens-table-from-save-non-expanding-hack save)))))
     (if plot-spec
	 (loop for line in plot-spec collect
	       (subst-keyword-arg :co line (if (ag-name-p (car line)) "gray90" "red") :not-found-action :add))
       '((default :wn ""))))
   :not-found-action :add))

(defun set-save-colors-to-ag-blue-sr-red (save)
  (set-plot-spec-in-save
   save
   (let ((plot-spec (if (plot-spec-from-save save)
                        (plot-spec-from-save save)
                      (generate-plot-spec (hi-table-antigens-table-from-save-non-expanding-hack save)))))
     (if plot-spec
	 (loop for line in plot-spec collect
	       (subst-keyword-arg :co line (if (ag-name-p (car line)) "blue" "red") :not-found-action :add))
       '((default :wn ""))))
   :not-found-action :add))

(defun set-save-coords-colors (save coords-colors &optional &key (not-found-action :error))
  (if (plot-spec-from-save save)
      (set-plot-spec-in-save
       save
       (let ((plot-spec (plot-spec-from-save save))
	     (table-names (hi-table-antigens (table-from-save save))))
	 (if plot-spec
	     (loop for line in plot-spec 
		 for table-name in table-names 
		 for coords-color in coords-colors collect
		   (if (not (equal table-name (car line)))
		       (error "Currently, plot spec order must be same as table order")
		     (subst-keyword-arg :co line coords-color :not-found-action :add)))
	   '((default :wn "")))))
    (set-save-keyword-entry
     save
     :coords-colors coords-colors
     :not-found-action not-found-action)))

(defun set-save-coords-colors-alist (save full-name-color-alist &optional &key (not-found-action :error))
  ;; should check that all names in the alist are in the save, but am not right now
  (if (plot-spec-from-save save)
      (set-plot-spec-in-save
       save
       (let ((plot-spec (plot-spec-from-save save))
	     (table-names (hi-table-antigens (table-from-save save))))
	 (if plot-spec
	     (loop for line in plot-spec 
		 for table-name in table-names collect
		   (if (not (equal table-name (car line)))
		       (error "Currently, plot spec order must be same as table order")
		     (if (assoc table-name full-name-color-alist)
                         (subst-keyword-arg :co line (assoc-value-1 table-name full-name-color-alist) :not-found-action :add)
                       line)))
	   '((default :wn "")))))
    (error "No plot-spec in save, currently must exist, though is easy to create one")))

(defun set-save-coords-name-colors (save coords-name-colors &optional &key (not-found-action :error))
  (set-save-keyword-entry
   save
   :coords-name-colors coords-name-colors
   :not-found-action not-found-action))

(defun color-difference-between-saves (save other-save &optional &key (new-color "#ff0000"))
  (set-save-coords-colors
   save
   (let ((colors      (coords-colors-from-save save))
	 (names       (hi-table-antigens (table-from-save save)))
	 (other-names (hi-table-antigens (table-from-save other-save))))
     (loop for name in names
	 for color in colors collect
	   (if (member name other-names)
	       color
	     new-color)))))

(defun set-save-coords-names-working-copy (save coords-names-working-copy &optional &key (not-found-action :error))
  (set-save-keyword-entry
   save
   :coords-names-working-copy coords-names-working-copy
   :not-found-action not-found-action))

(defun set-mds-dimensions (save num-dimensions &optional &key (not-found-action :error))
  (if (starting-coordss-from-save save)
      (cerror "continue anyway?"
	      "setting num dimensions, but there are already starting coords, check num dims already there"))
  (set-save-keyword-entry
   save
   :mds-dimensions num-dimensions
   :not-found-action not-found-action))

(defun set-landscape-titers-in-save (save landscape-titers &optional &key (not-found-action :error))
  (set-save-keyword-entry save :landscape-titers landscape-titers :not-found-action not-found-action))


;;;----------------------------------------------------------------------
;;;                      misc accessors
;;;----------------------------------------------------------------------

(defun pre-merge-tables-from-save (save &optional &key (not-found-action :return-nil)) 
  (get-save-keyword-entry save :pre-merge-tables :not-found-action not-found-action))



(defun acmacs-a1-antigens-from-save (save &optional &key (not-found-action :return-nil)) 
  (get-save-keyword-entry save :acmacs-a1-antigens :not-found-action not-found-action))

(defun acmacs-b1-antigens-from-save (save &optional &key (not-found-action :return-nil)) 
  (get-save-keyword-entry save :acmacs-b1-antigens :not-found-action not-found-action))

(defun acmacs-a1-sera-from-save (save &optional &key (not-found-action :return-nil)) 
  (get-save-keyword-entry save :acmacs-a1-sera :not-found-action not-found-action))

(defun acmacs-b1-sera-from-save (save &optional &key (not-found-action :return-nil)) 
  (get-save-keyword-entry save :acmacs-b1-sera :not-found-action not-found-action))



(defun date-from-save (save &optional &key (not-found-action :return-nil)) 
  (get-save-keyword-entry save :date :not-found-action not-found-action))

(defun rbc-species-from-save (save &optional &key (not-found-action :return-nil)) 
  (get-save-keyword-entry save :rbc-species :not-found-action not-found-action))

(defun lab-from-save (save &optional &key (not-found-action :return-nil)) 
  (get-save-keyword-entry save :lab :not-found-action not-found-action))

(defun minimum-column-basis-from-save (save &optional &key (not-found-action :return-nil)) 
  (get-save-keyword-entry save :minimum-column-basis :not-found-action not-found-action))

(defun allow-titers-less-than-from-save (save &optional &key (not-found-action :return-nil)) 
  (get-save-keyword-entry save :allow-titers-less-than :not-found-action not-found-action))

(defun titer-type-from-save (save &optional &key (not-found-action :return-nil)) 
  (get-save-keyword-entry save :titer-type :not-found-action not-found-action))


;;;----------------------------------------------------------------------
;;;                      misc manipulation
;;;----------------------------------------------------------------------

(defun set-names-in-save (save new-names)
  (let* ((old-table (table-from-save save))
	 (old-names (hi-table-antigens old-table)))
    (if (not (= (length old-names)
		(length new-names)))
	(error "~%Number of existing names does not equal the number of new names~%"))
    (set-names-in-save-from-name-alist save (transpose old-names new-names))))

(defun set-names-in-save-from-name-alist (save old-new-alist &optional &key permit-alist-having-names-not-in-save)
  (let* ((old-table (table-from-save save))
	 (old-names (hi-table-antigens old-table))
	 (new-names (loop for old-name in old-names collect
			  (if (assoc old-name old-new-alist)
			      (assoc-value-1 old-name old-new-alist)
			    old-name)))
	 (old-new-dotted-pair-alist (mapcar (^ (l) (cons (nth 0 l) (nth 1 l))) old-new-alist)))

    (loop for old-name-to-replace in (nths 0 old-new-alist) do
	  (if (not (member old-name-to-replace old-names))
	      (if permit-alist-having-names-not-in-save
		  ;; the below is quoted out as it causes so many messages when doing ref ag
		  '(format t "~%The name ~a is not in the save I've been asked to do the name replacement in (might be ag-sr table, and you've not included the -ag or -sr suffix?) you have specified this is only a warning, maybe this is a ref ag merge generateion~%" old-name-to-replace)
	      (error "~%The name ~a is not in the save I've been asked to do the name replacement in (might be ag-sr table, and you've not included the -ag or -sr suffix?)~%" old-name-to-replace))))

    ;; this function is more complex than it seems it should be.
    ;; need to special case the hi-table, and the reference-antigens, as they do not have -ag -sr prefixes
    (let* ((interim-save (set-table-in-save  ;; because if the save is for an -ag-sr table the names in the save will be suffixless, and to get the sera set
			  (sublis            
			   old-new-dotted-pair-alist
			   save)
			  (make-hi-table
			   new-names
			   new-names
			   (hi-table-values old-table)
			   (hi-table-name   old-table))))
	   (plot-spec (plot-spec-from-save interim-save))
	   (next-interim-save 
	    (if (not plot-spec)
		interim-save
	      (progn
		(if (not (equal (nths 0 plot-spec) new-names))
		    (error "~%The names in the table and the names in the plotspec are not in the same order~%"))
		(set-plot-spec-in-save
		 interim-save
		 (loop for (ignore-name . rest) in plot-spec 
		     for new-name in new-names collect
		       (let ((new-name-without-suffix-if-suffix (if (ag-or-sr-name-p new-name) (remove-ag-sr-from-name new-name) new-name)))
			 ignore-name  ;; to stop the compiler bitching
			 (cons new-name
			       (let ((interim-rest (subst-keyword-arg :nm rest (string new-name-without-suffix-if-suffix) :not-found-action :ignore)))
				 (if (equal "" (snoop-keyword-arg :wn rest))
				     interim-rest
				   (subst-keyword-arg :wn interim-rest (string new-name-without-suffix-if-suffix))))))))))))
      (setq next-interim-save
        (if (reference-antigens-from-save next-interim-save)
            (set-reference-antigens-in-save 
             next-interim-save
             (sublis 
              (loop for (old new) in old-new-alist
                  when (cond ((serum-name-p   old) nil)
                             ((antigen-name-p old) t)
                             (t t))  ;; when not an ag-sr-table
                  collect (cons (remove-ag-sr-from-name old)  ;; benign if is not -ag
                                (remove-ag-sr-from-name new)))
              (reference-antigens-from-save next-interim-save)))
          next-interim-save))
      (setq next-interim-save
        (if (raise-points-from-save next-interim-save)
            (set-raise-points-in-save 
             next-interim-save
             (sublis 
              old-new-alist
              (raise-points-from-save next-interim-save)))
          next-interim-save))
      (setq next-interim-save
        (if (lower-points-from-save next-interim-save)
            (set-lower-points-in-save 
             next-interim-save
             (sublis 
              old-new-alist
              (lower-points-from-save next-interim-save)))
          next-interim-save))
      )))


;; ----------- removing leading zeros from isolation number -------------

(defun remove-leading-zeros-from-string (string)
  (string-left-trim (list #\0) string))

(defun remove-leading-zeros-from-isolation-date-in-name (name)
  ;; special case this, assume canonical name, as it currently exists
  (setq name (string name))
  (read-from-string
   (if (substring-after-char #\/ (substring-after-char #\/ name))
       (let ((prefix (substring-before-char #\/ name))
	     (isolation-number (substring-before-char #\/ (substring-after-char #\/ name)))
	     (suffix (substring-after-char #\/ (substring-after-char #\/ name))))
	 (format nil "~a/~a/~a" prefix (remove-leading-zeros-from-string isolation-number) suffix))
     name)))

(defun remove-leading-zeros-from-isolation-dates-in-save (save)
  (let ((interim-save (set-names-in-save
		       save
		       (loop for name in (hi-table-antigens (table-from-save save)) collect
			     (let ((new-name (remove-leading-zeros-from-isolation-date-in-name name)))
			       (if (not (eql new-name name))
				   (print (list name new-name)))
			       new-name)))))
    (setq interim-save 
      (if (reference-antigens-from-save interim-save)
          (set-reference-antigens-in-save
           interim-save
           (mapcar #'remove-leading-zeros-from-isolation-date-in-name (reference-antigens-from-save save)))
        interim-save))
    (setq interim-save 
      (if (raise-points-from-save interim-save)
          (set-raise-points-in-save
           interim-save
           (mapcar #'remove-leading-zeros-from-isolation-date-in-name (raise-points-from-save save)))
        interim-save))
    (setq interim-save 
      (if (lower-points-from-save interim-save)
          (set-lower-points-in-save
           interim-save
           (mapcar #'remove-leading-zeros-from-isolation-date-in-name (lower-points-from-save save)))
        interim-save))))
    


;;;----------------------------------------------------------------------
;;;           outputing save in quick text format for eu
;;;----------------------------------------------------------------------

(defun save-to-simple-text (save &optional &key (stream t) filename (if-exists :error))
  (if filename
      (with-open-file (output-stream filename :direction :output :if-exists if-exists)
	(save-to-simple-text save :stream output-stream))
    (let ((table (un-asl-hi-table-from-save save))
	  (coordss (coordss (starting-coordss-from-save save)))
          (num-dimensions (num-dimensions-from-save save)))
      (format stream "; mds table ~a" (if (member (user-name) '("nsl25" "Nicola Lewis")) "equine" "hi-table"))
      (newline stream :times 1)
      (pp-hi-table table 'full nil nil :stream stream)
      (newline stream :times 1)
      (format stream "; mds table end")
      (newline stream :times 1)

      (let ((ref-antigens (eval (snoop-keyword-arg :reference-antigens (cddr save)
                                                   :not-found-action :return-nil))))
        (if ref-antigens
            (progn
              (format stream "; mds reference antigens~%")
              (fll (mapcar #'list ref-antigens) :stream stream)
              (format stream "; mds reference antigens end~%"))))

      (format stream "; mds coordinates ~dd~%" num-dimensions)
      (fll coordss :stream stream)
      (format stream "; mds coordinates end~%")

      (format stream "; mds columns adjusts~%")
      (fll (mapcar #'list (nthcdr (length 
                                   (hi-table-antigens (un-asl-hi-table-from-save save)))
                                  (col-bases (starting-coords-from-save save))))
           :stream stream)
      (format stream "; mds columns adjusts end~%")

      (let ((vectors (canvas-basis-vectors-from-save save)))
        (if (not (equal vectors 'not-available))
            (progn
              (format stream "; mds coordinates transformation ~dd~%" num-dimensions)
              (fll vectors :stream stream)
              (format stream "; mds coordinates transformation end~%")
              )))

      (let ((vectors (canvas-coord-scale-from-save save)))
        (if (not (equal vectors 'not-available))
            (progn
              (format stream "; mds coordinates scale ~dd~%" num-dimensions)
              (fll (mapcar #'list vectors) :stream stream)
              (format stream "; mds coordinates scale end~%")
              )))

      (let ((basis-vector-point-indices (basis-vector-point-indices-from-save save)))
        (if (not (equal basis-vector-point-indices 'not-available))
            (progn
              (format stream "; mds antigens indices to re-orient~%")
              (fll basis-vector-point-indices :stream stream)
              (format stream "; mds antigens indices end~%")
              )))

      (let ((stress (starting-coords-stress-from-save save)))
        (if (not (equal stress 'not-available))
            (progn
              (format stream "; mds stress~%")
              (format stream "~d~%" stress)
              (format stream "; mds stress end~%")
              )))

      (format stream "; mds plot specification")
      (newline stream :times 1)
      (fll (plot-spec-from-save save) :stream stream :use~s t)
      (format stream "; mds plot specification end")
      (newline stream :times 1)

      (let ((raise-points (raise-points-from-save save)))
        (if raise-points
            (progn
              (format stream "; mds plot raise points~%")
              (fll (mapcar #'list raise-points) :stream stream)
              (format stream "; mds plot raise points end~%"))))
        
      (let ((lower-points (lower-points-from-save save)))
        (if lower-points
            (progn
              (format stream "; mds plot lower points~%")
              (fll (mapcar #'list lower-points) :stream stream)
              (format stream "; mds plot lower points end~%"))))
        
      )))



;;;----------------------------------------------------------------------
;;;                  output save in acmacs-b1 format
;;;----------------------------------------------------------------------

(defun infer-save-name-from-filename (filename)
  ;; extract name from after the final "/" and before the final "."
  (let* ((reverse (reverse filename))
         (pre-suffix (if (string-member "." reverse)    (substring-after-char  #\. reverse)    reverse))
         (post-slash (if (string-member "/" pre-suffix) (substring-before-char #\/ pre-suffix) pre-suffix)))
    (reverse post-slash)))

(defun save-to-acmacs-b1-format (save &optional &key (stream t) filename name-override (if-exists :error))

  ;; name-override will typically not be passed by user, but is typically used to replace zmerged by the name of the file
  (setq name-override
    (if (not name-override)
        (let ((name-from-table-in-save (hi-table-name-table-from-save-non-expanding-hack save)))
          (if (eql 'zmerged name-from-table-in-save)
              (if filename
                  (infer-save-name-from-filename filename)
                'zmerged)
            name-from-table-in-save))
      name-override))

  (if filename

      (with-open-file (output-stream filename :direction :output :if-exists if-exists)
	(save-to-acmacs-b1-format save :stream output-stream :name-override name-override))

    (let* ((table (un-asl-hi-table-from-save save))
           (antigens (hi-table-antigens table))
           (sera     (hi-table-sera     table))
           (num-antigens (hi-table-length table))
           (num-sera     (hi-table-width  table))
           (reference-antigens (reference-antigens-from-save save))
           (batch-runs   (if (batch-runs-from-save save)
                             (batch-runs-from-save save)
                           (if (starting-coordss-from-save save)
                               (list (list (starting-coordss-from-save save) "stress-not-calculated" nil nil))
                             nil)))
           (plot-spec (plot-spec-from-save save))
           (num-dimensions (mds-dimensions-from-save save))
           (canvas-coord-transformations (canvas-coord-transformations-from-save save))
           (canvas-basis-vector-0 (snoop-keyword-arg :canvas-basis-vector-0 canvas-coord-transformations))
           (canvas-basis-vector-1 (snoop-keyword-arg :canvas-basis-vector-1 canvas-coord-transformations))
           (canvas-x-coord-scale (snoop-keyword-arg :canvas-x-coord-scale canvas-coord-transformations))
           (canvas-y-coord-scale (snoop-keyword-arg :canvas-y-coord-scale canvas-coord-transformations)))

      (format stream "@ acmacs-txt version b1-2~%")
      (format stream "# Generated by lispmds on ~a~%" (time-and-date))
      (newline stream)
      (format stream "@ generator lispmds~%")
      (format stream "@ chart~%")
      (format stream "@ table antigenic flu human~%")               ;; don't know whether flu or human
      (format stream "@ default flu type A_H3N2~%")
      ;;(format stream "@ table titer type normal~%")
      (format stream "@ table name ~a~%" name-override)
      (format stream "@ date ~a~%"                   (if (date-from-save save) (date-from-save save) "ask-user-if-possible-otherwise-set-to-today"))
      (format stream "@ rbc_species ~a~%"            (if (rbc-species-from-save save) (rbc-species-from-save save) "unknown"))
      (format stream "@ lab ~a~%"                    (if (lab-from-save save) (lab-from-save save) (if (user-name) (user-name) "unknown-user")))
      (format stream "@ minimum column basis ~a~%"   (minimum-column-basis-from-save save))  
      (format stream "@ allow titers less than ~a~%" (allow-titers-less-than-from-save save))
      (if (titer-type-from-save save) (format stream "@ titer type ~a~%" (titer-type-from-save save)))
      (newline stream)
      (format stream "@ antigens ~d~%" num-antigens)
      (if (or (acmacs-a1-antigens-from-save save)
              (acmacs-b1-antigens-from-save save))
          (loop for i below (hi-table-length table)
              for antigen in (or (acmacs-a1-antigens-from-save save)
                                 (acmacs-b1-antigens-from-save save)) do
                (let ((name-component-list antigen))
                  (format stream "~d~:{~a~a~}~%" i (transpose (replicate-into-list #\tab (length name-component-list)) name-component-list))))
        (loop for i below num-antigens
            for antigen in (hi-table-antigens table) do
              (format stream "~d~alispmds_name~a~a~areference~a~a~%" 
                      i #\tab #\tab antigen #\tab #\tab (if (member antigen reference-antigens) "True" "False"))))
      
      (newline stream)
      (format stream "@ sera ~d~%" num-sera)
      (if (or (acmacs-a1-sera-from-save save)
              (acmacs-b1-sera-from-save save))
          (loop for i below num-sera
              for serum in (or (acmacs-a1-sera-from-save save)
                               (acmacs-b1-sera-from-save save)) do
                (let ((name-component-list serum))
                  (format stream "~d~:{~a~a~}~%" i (transpose (replicate-into-list #\tab (length name-component-list)) name-component-list))))
        (loop for i below num-sera
            for serum in (hi-table-sera table) do
              (format stream "~d~alispmds_name~a~a~%" i #\tab #\tab serum)))
      
      (newline stream)
      (format stream "@ titers antigenic ~d ~d~%" num-antigens num-sera)
      (fll (subst '* 'dont-care (hi-table-values table)) :stream stream :use~s t)

      (if batch-runs
          (progn
            (newline stream :times 3)
            (format stream "@ projections ~d~%" (length batch-runs))
            (loop for i below (length batch-runs)
                for (coordss stress) in batch-runs do
                  (progn
                    (newline stream)
                    (format stream "@ projection ~d stress ~a~%~%" i stress)
                    (format stream "@ projection ~d column-bases ~d~%~{~d ~}~%~%" 
                            i
                            (length (hi-table-sera table))
                            (nthcdr (length (hi-table-antigens table)) (col-bases coordss)))
                    (format stream "@ projection ~d layout ~d~%" i num-dimensions)
                    (fll 
                     (coordss coordss)
                     :stream stream)
                    (if canvas-basis-vector-0
                        (progn
                          (format stream "~%@ projection ~d layout transformation lispmds ~d~%" i num-dimensions)
                          (fll (list canvas-basis-vector-0 canvas-basis-vector-1) :stream stream)
                          (newline stream)))
                    (if canvas-x-coord-scale
                        (progn
                          (format stream "@ projection ~d layout scale lispmds ~d~%" i num-dimensions)
                          (format stream "~d ~d~%~%" canvas-x-coord-scale canvas-y-coord-scale)))
                    (newline stream)))))
      
      (if plot-spec
          (progn
            (newline stream)
            (format stream "@ plot_spec lispmds ~d~%" (length plot-spec))
            (fll (loop for (name . rest) in plot-spec collect
                       (cons (read-from-string (apply #'format nil "~d~a"
                                                      (cond ((ag-name-p name) (list (position (remove-ag-sr-from-name name) antigens) "-AG"))
                                                            ((sr-name-p name) (list (position (remove-ag-sr-from-name name) sera)     "-SR"))
                                                            (t                (list (position name antigens) "")))))
                             rest))
                 :stream stream :use~s t)))
      
      (newline stream)
      (format stream "@ end~%"))))
    

;;;----------------------------------------------------------------------
;;;                        overlay merge saves
;;;----------------------------------------------------------------------

#|
original for two saves
(defun overlay-merge-saves (master-save slave-save &optional &key scalep slave-indices)
  (let ((slave-save (transform-slave-save-best-coords-by-procrustes-to-master-save-best-coordss-set-as-starting-coordss-in-new-save 
		     slave-save
		     master-save
		     :scalep scalep
		     :slave-indices slave-indices)))
    (multiple-value-bind (slave-coordss ignore-slave-more slave-col-bases slave-row-adjusts)
	(deconstruct-coordss-plus-more (starting-coordss-from-save slave-save))
      ignore-slave-more
      (multiple-value-bind (master-coordss ignore-master-more master-col-bases master-row-adjusts)
	  (deconstruct-coordss-plus-more (starting-coordss-from-save master-save))
	ignore-master-more
	(let* ((merge-table  (table-from-save
			      (merge-tables 
			       (list 
				(un-asl-hi-table (table-from-save master-save))
				(un-asl-hi-table (table-from-save slave-save))))))
	       (slave-names  (hi-table-antigens (table-from-save slave-save)))
	       (master-names (hi-table-antigens (table-from-save master-save)))
	       (merge-names  (hi-table-antigens merge-table))
	       (merge-coordss (apply #'make-coordss-plus-more
				     (apply #'transpose
				      (loop for merge-name in merge-names collect
					    (let ((slave-position  (position merge-name slave-names))
						  (master-position (position merge-name master-names)))
					      (cond ((and slave-position master-position)
						     (list (mapcar #'av (transpose (nth slave-position slave-coordss) (nth master-position master-coordss)))
							   (max (nth slave-position slave-col-bases)   (nth master-position master-col-bases))
							   (av (list (nth slave-position slave-row-adjusts) (nth master-position slave-row-adjusts)))))
						    (slave-position
						     (list (nth slave-position slave-coordss)    
							   (nth slave-position slave-col-bases)  
							   (nth slave-position slave-row-adjusts)))
						    (master-position
						     (list (nth master-position master-coordss) 
							   (nth master-position master-col-bases)
							   (nth master-position master-row-adjusts)))
						    (t (error "Unuexpected case, contact Derek"))))))))
	       (master-plot-spec (plot-spec-from-save master-save))
	       (slave-plot-spec (plot-spec-from-save slave-save))
	       (merge-plot-spec (loop for merge-name in merge-names 
				    when (or (assoc merge-name master-plot-spec)
					     (assoc merge-name slave-plot-spec))
				    collect (if (assoc merge-name master-plot-spec)
						(assoc merge-name master-plot-spec)  ;; take from master if there are both
					      (assoc merge-name slave-plot-spec)))))
	  (make-save-form
	   :hi-table merge-table
	   :starting-coordss merge-coordss
	   :plot-spec merge-plot-spec
	   :canvas-coord-transformations (canvas-coord-transformations-from-save master-save)
	   :reference-antigens (my-intersection (reference-antigens-from-save master-save) (reference-antigens-from-save slave-save))))))))
||#

(defun overlay-merge-saves-filenames (filenames &optional &key 
                                                          scalep
                                                          (table-output-stream t)
                                                          table-output-filename
                                                          (remerge-from-original-tables t)
                                                          (if-exists-action :error))
  (overlay-merge-saves (mapcar #'fi-in filenames) 
                       :scalep scalep
                       :table-output-stream          table-output-stream
                       :table-output-filename        table-output-filename
                       :remerge-from-original-tables remerge-from-original-tables
                       :if-exists-action             if-exists-action))


(defun overlay-merge-saves (saves &optional &key 
                                            save-to-orient-to
                                            scalep
                                            (table-output-stream t)
                                            table-output-filename
                                            (remerge-from-original-tables t)
                                            (if-exists-action :error))
  (if (not save-to-orient-to)
      (progn
	(format t "~2%   >>>> overlay-merge-saves not called with save-to-orient-to, so orienting to the first save, are you sure that this is what you want? <<<<~2%")
	(setq save-to-orient-to (car saves))))
  (let* ((saves (mapcar (^ (slave-save)
			   (transform-slave-save-best-coords-by-procrustes-to-master-save-best-coordss-set-as-starting-coordss-in-new-save 
			    slave-save
			    save-to-orient-to
			    :scalep scalep))
			saves))
	 (starting-coordss-s (mapcar #'starting-coordss-from-save saves))
	 (coordss-s          (mapcar #'coordss                    starting-coordss-s))
	 (col-bases-s        (mapcar #'col-bases                  starting-coordss-s))
	 (row-adjusts-s      (mapcar #'row-adjusts                starting-coordss-s))
	 (names-s            (mapcar #'asl-hi-table-antigens-from-unasl-hi-table (mapcar #'un-asl-hi-table-from-save saves)))

	 (tables             (if remerge-from-original-tables
                                 (apply #'nary-union  ;; overlay merge decision here, to do union or append.
                                        (mapcar
                                         (^ (save) (if (pre-merge-tables-from-save save)
                                                       (pre-merge-tables-from-save save)
                                                     (list (un-asl-hi-table-from-save save))))
                                         saves))
                               (mapcar #'un-asl-hi-table-from-save saves)))
	 (merge-table        (table-from-save (merge-tables tables
							    :table-output-stream table-output-stream
							    :filename table-output-filename
							    :if-exists-action if-exists-action)))
	 (merge-names        (hi-table-antigens merge-table))

	 (merge-coordss (apply #'make-coordss-plus-more
			       (apply #'transpose
				      (loop for merge-name in merge-names collect
					    (let* ((positions (mapcar (^ (names) (position (print merge-name) names)) names-s))
						   (coords-colbasis-rowadjust-triples
						    (loop for position in positions
							for coordss in coordss-s
							for col-bases in col-bases-s
							for row-adjusts in row-adjusts-s 
							when position
							collect (list (nth position coordss)
								      (nth position col-bases)
								      (nth position row-adjusts))))
						   (coords-av      (mapcar #'av (print (apply-transpose (nths 0 coords-colbasis-rowadjust-triples)))))
						   (col-bases-max  (apply-max                    (nths 1 coords-colbasis-rowadjust-triples)))
						   (row-adjusts-av (av                           (print (nths 2 coords-colbasis-rowadjust-triples)))))
					      (list coords-av col-bases-max row-adjusts-av))))))

	 (plot-spec-s (mapcar #'plot-spec-from-save saves))
	 ;; the below is not complete enough, we have cases where a reference antigen is not a reference antigen at first 
	 ;; and so its plot spec changes, but the below only picks up the first instance.
	 ;; either do something squirley below, but better, do not expect the plotspec to come out right.
	 ;; in this latter case the best thing to do would be have no plot spec so we do not get something
	 ;; that is partially right, and thus which might be misleading.	
	 (merge-plot-spec (loop for merge-name in merge-names
			      when (apply-append (mapcar (^ (plot-spec) (assoc merge-name plot-spec)) plot-spec-s))
			      collect (loop for plot-spec in plot-spec-s 
					  do (if (assoc merge-name plot-spec)
						 (return (assoc merge-name plot-spec)))
					  finally (error "unexpected case, sorry, please contact antigenic-cartography support")))))

    (make-save-form
     :hi-table merge-table
     :pre-merge-tables tables
     :starting-coordss merge-coordss
     :plot-spec merge-plot-spec
     :canvas-coord-transformations (canvas-coord-transformations-from-save save-to-orient-to)
     :reference-antigens (apply #'nary-union (mapcar #'reference-antigens-from-save saves))
     :raise-points       (apply #'nary-union (mapcar #'raise-points-from-save       saves))
     :lower-points       (apply #'nary-union (mapcar #'lower-points-from-save       saves)))))

(defun merge-saves-no-coordss (saves &optional &key 
					       (table-output-stream t)
					       table-output-filename
                                               (remerge-from-original-tables t)
					       (if-exists-action :error)
					       (multiple-values-f #'average-multiples-unless-sd-gt-1-ignore-thresholded-unless-only-entries-then-min-threshold))
  (let* (;; comment out the below, is not needed (we are explictly not doing coords, and also the procrustes barfs
	 ;;   when there are no coords passed, which is the case when we are merging saves which contain no coords
	 ;;(saves (cons (car saves)
	 ;;	      (mapcar (^ (slave-save)
	 ;;			 (transform-slave-save-best-coords-by-procrustes-to-master-save-best-coordss-set-as-starting-coordss-in-new-save 
	 ;;			  slave-save
	 ;;			  (car saves)
	 ;;			  :scalep scalep))
	 ;;		      (cdr saves))))
	 (tables             (if remerge-from-original-tables
                                 (map-append
                                  (^ (save) (if (pre-merge-tables-from-save save)
                                                (pre-merge-tables-from-save save)
                                              (list (un-asl-hi-table-from-save save))))
                                  saves)
                               (mapcar #'un-asl-hi-table-from-save saves)))
	 (merge-table        (table-from-save (merge-tables tables
							    :multiple-values-f multiple-values-f
							    :table-output-stream table-output-stream
							    :filename table-output-filename
							    :if-exists-action if-exists-action)))
	 (merge-names        (hi-table-antigens merge-table))
	 (plot-spec-s        (mapcar #'plot-spec-from-save saves))
	 (merge-plot-spec    (loop for merge-name in merge-names
				 when (apply-append (mapcar (^ (plot-spec) (assoc merge-name plot-spec)) plot-spec-s))
				 collect (loop for plot-spec in plot-spec-s 
					     do (if (assoc merge-name plot-spec)
						    (return (assoc merge-name plot-spec)))
					     finally (error "unexpected case, sorry, please contact antigenic-cartography support")))))
    (make-save-form
     :hi-table merge-table
     :pre-merge-tables tables
     :plot-spec merge-plot-spec
     :canvas-coord-transformations (canvas-coord-transformations-from-save (car saves))
     :reference-antigens (apply #'nary-union (mapcar #'reference-antigens-from-save saves))
     :raise-points       (apply #'nary-union (mapcar #'raise-points-from-save       saves))
     :lower-points       (apply #'nary-union (mapcar #'lower-points-from-save       saves)))))
	   



#|
(setq overlay-merge-1
  (overlay-merge-saves
   (list 
    (fi-in "mds/investigations/strain-selection-meeting/database/cdc/runs/20040820-10-runs/batch-processing/20040505/merge-randomized/save-after-runs-reoriented.save"))))

(setq overlay-merge-2
  (overlay-merge-saves
   (list 
    (fi-in "mds/investigations/strain-selection-meeting/database/cdc/runs/20040820-10-runs/batch-processing/20021009/merge-randomized/save-after-runs-reoriented.save")
    (fi-in "mds/investigations/strain-selection-meeting/database/cdc/runs/20040820-10-runs/batch-processing/20040505/merge-randomized/save-after-runs-reoriented.save"))))

(setq overlay-merge-3
  (overlay-merge-saves
   (list 
    (fi-in "mds/investigations/strain-selection-meeting/database/cdc/runs/20040820-10-runs/batch-processing/20021009/merge-randomized/save-after-runs-reoriented.save")
    (fi-in "mds/investigations/strain-selection-meeting/database/cdc/runs/20040820-10-runs/batch-processing/20040505/merge-randomized/save-after-runs-reoriented.save")
    (fi-in "mds/investigations/strain-selection-meeting/database/cdc/runs/20040820-10-runs/batch-processing/20040519/merge-randomized/save-after-runs-reoriented.save"))))

(setq overlay-merge-cdc-nimr
  (overlay-merge-saves
   (list 
    (fi-in "mds/investigations/strain-selection-meeting/database/scripts/reference-antigen-comparison-grouped-names-100-runs-test/save-after-runs-reoriented.save")
    (fi-in "mds/investigations/strain-selection-meeting/database/nimr/investigations/reference-antigen-map/100-runs-uniform-names/save-after-runs-reoriented.save"))))


|#



(defun merge-batch-runs-from-saves (saves)
  (set-starting-coordss-and-batch-runs-from-batch-runs-in-save 
   (car saves)
   (sort-batch-runs (apply #'append (mapcar #'batch-runs-from-save saves)))))



;;;----------------------------------------------------------------------
;;;                      overlay merge done again
;;;    with space optimization (i think it was) by not explainding 
;;;    the hi tables.  should unify with the related functions above
;;;    at some point
;;;----------------------------------------------------------------------

(defun unexpanded-hi-table-from-save (save)
  (nth 1 save))

(defun un-asl-hi-table-from-save (save)
  ;; efficiency hack to avoid expanding the contracting large tables
  (let-list ((hi-in antigens sera values name) (unexpanded-hi-table-from-save save))
	    (if (not (eql 'hi-in hi-in))
		(error "expected hi-in form, an unexpanded hi table"))
	    (hi-table-un-std-log-titers
	     (make-hi-table
	      (eval antigens)
	      (eval sera)
	      (*-to-dont-care (eval values))
	      (eval name)))))

(defun hi-table-in-save-p (save)
  (eql 'hi-in (nth 1 (nth 1 save))))

(defun hi-table-antigens-from-unexpanded-hi-table (hi-table)
  (if (not (eql 'hi-in (car hi-table)))
      (error "expected hi-in form, an unexpanded hi table")
    (append (mapcar #'suffix-as-ag (nth 1 hi-table))
	    (mapcar #'suffix-as-sr (nth 2 hi-table)))))

(defun hi-table-antigens-from-unexpanded-hi-table-fixed (hi-table)
  (if (not (eql 'hi-in (car hi-table)))
      (error "expected hi-in form, an unexpanded hi table")
    (append (mapcar #'suffix-as-ag (eval (nth 1 hi-table)))
	    (mapcar #'suffix-as-sr (eval (nth 2 hi-table))))))

(defun hi-table-antigens-from-unexpanded-unasl-hi-table (hi-table)
  (if (not (eql 'hi-in (car hi-table)))
      (error "expected hi-in form, an unexpanded hi table")
    (eval (nth 1 hi-table))))

(defun hi-table-sera-from-unexpanded-unasl-hi-table (hi-table)
  (if (not (eql 'hi-in (car hi-table)))
      (error "expected hi-in form, an unexpanded hi table")
    (eval (nth 2 hi-table))))


(defun hi-table-antigens-table-from-save-non-expanding-hack (save)
  (hi-table-antigens-from-unexpanded-hi-table-fixed
   (unexpanded-hi-table-from-save
    save)))

(defun hi-table-antigens-unasl-table-from-save-non-expanding-hack (save)
  (hi-table-antigens-from-unexpanded-unasl-hi-table
   (unexpanded-hi-table-from-save
    save)))

(defun hi-table-sera-unasl-table-from-save-non-expanding-hack (save)
  (hi-table-sera-from-unexpanded-unasl-hi-table
   (unexpanded-hi-table-from-save
    save)))

(defun hi-table-name-table-from-save-non-expanding-hack (save) 
  (eval (nth 4 (unexpanded-hi-table-from-save save))))
   

(defun make-save-form-from-unexpanded-hi-table (&key hi-table
						     (starting-coordss          'not-passed)           ;;  **************** CAREFUL ***************
						     (batch-runs                'not-passed)           ;;  when adding a parameter, also add to the
						     (mds-dimensions            'not-passed)           ;;  2 lists in the body.  this could be a macro
						     (coords-colors             'not-passed)           ;;  but then it would be a bit confusing in a different way
						     (coords-dot-sizes          'not-passed)
						     (coords-names              'not-passed)
						     (coords-names-working-copy 'not-passed)
						     (coords-name-sizes         'not-passed)
						     (coords-name-colors        'not-passed)
						     (coords-shapes             'not-passed)
						     (moveable-coords           'not-passed)
						     (unmoveable-coords         'not-passed)
						     (adjustable-rows           'not-passed)
						     (adjustable-columns        'not-passed)
						     (unmoveable-dimensions     'not-passed)
						     (unmoveable-dimensions-in-second-phase 'not-passed)
						     (dim-anneal-coefficients   'not-passed)
						     ;;show-error-lines    ;; not sure, probably not right now
						     (coords-outline-colors     'not-passed)
						     (plot-spec                 'not-passed)
						     (canvas-coord-transformations 'not-passed)
						     (constant-stress-radial-data  'not-passed)
						     (reference-antigens           'not-passed)
						     reassortments
						     equivalent-row-names
						     equivalent-column-names
						     (procrustes-data            'not-passed)
						     (raise-points               'not-passed)
						     (lower-points               'not-passed)
						     (error-connection-prediction-line-data 'not-passed))
  
  ;; ignore these for now
  reassortments
  equivalent-row-names
  equivalent-column-names
  
  `(make-master-mds-window
    ,hi-table
    ,@(loop for arg-name in '(starting-coordss
			      batch-runs
			      mds-dimensions    ;; check we set
			      ;;coords-colors                now in plot-spec
			      ;;coords-dot-sizes             now in plot-spec
			      ;;coords-names                 now in plot-spec
			      ;;coords-names-working-copy    now in plot-spec
			      ;;coords-name-sizes            now in plot-spec
			      ;;coords-name-colors           now in plot-spec
			      ;;coords-shapes                now in plot-spec
			      moveable-coords
			      unmoveable-coords
			      adjustable-rows
			      adjustable-columns
			      unmoveable-dimensions
			      unmoveable-dimensions-in-second-phase
			      dim-anneal-coefficients
			      ;;show-error-lines    ;; not sure, probably not right now
			      ;;coords-outline-colors        now in plot-spec
			      plot-spec
			      canvas-coord-transformations
			      constant-stress-radial-data
			      reference-antigens
			      procrustes-data
                              raise-points
                              lower-points
			      error-connection-prediction-line-data
			      )
	  for arg-value in (list starting-coordss
				 batch-runs
				 mds-dimensions    ;; check we set
				 ;;coords-colors                now in plot-spec
				 ;;coords-dot-sizes             now in plot-spec
				 ;;coords-names                 now in plot-spec
				 ;;coords-names-working-copy    now in plot-spec
				 ;;coords-name-sizes            now in plot-spec
				 ;;coords-name-colors           now in plot-spec
				 ;;coords-shapes                now in plot-spec
				 moveable-coords
				 unmoveable-coords
				 adjustable-rows
				 adjustable-columns
				 unmoveable-dimensions
				 unmoveable-dimensions-in-second-phase
				 dim-anneal-coefficients
				 ;;show-error-lines    ;; not sure, probably not right now
				 ;;coords-outline-colors        now in plot-spec
				 plot-spec
				 canvas-coord-transformations
				 constant-stress-radial-data
				 reference-antigens
				 procrustes-data
                                 raise-points
                                 lower-points
				 error-connection-prediction-line-data
				 )
	  when (not (eql 'not-passed arg-value))
	  append
	    `(,(read-from-string (string-append ":" (string arg-name))) ',arg-value))
    ,@(if (or (not (eql 'not-passed coords-colors))            
	      (not (eql 'not-passed coords-dot-sizes))         
	      (not (eql 'not-passed coords-names))             
	      (not (eql 'not-passed coords-names-working-copy))
	      (not (eql 'not-passed coords-name-sizes))        
	      (not (eql 'not-passed coords-name-colors))       
	      (not (eql 'not-passed coords-outline-colors))
	      (not (eql 'not-passed coords-shapes)))
	  (progn
	    (if (not (eql 'not-passed plot-spec))
		(error "Internal inconsistency.  Do not supply both plot-spec and coords-plot-spec details to make-save-form"))
	    `(:plot-spec
	      ',(generate-plot-spec 
		 (hi-table-antigens-from-unexpanded-hi-table hi-table)
		 :coords-colors             (if (eql 'not-passed coords-colors)             nil coords-colors)
		 :coords-dot-sizes          (if (eql 'not-passed coords-dot-sizes)          nil coords-dot-sizes)
		 :coords-names              (if (eql 'not-passed coords-names)              nil coords-names)
		 :coords-names-working-copy (if (eql 'not-passed coords-names-working-copy) nil coords-names-working-copy)
		 :coords-name-sizes         (if (eql 'not-passed coords-name-sizes)         nil coords-name-sizes)
		 :coords-name-colors        (if (eql 'not-passed coords-name-colors)        nil coords-name-colors)
		 :coords-outline-colors     (if (eql 'not-passed coords-outline-colors)     nil coords-outline-colors)
		 :coords-shapes             (if (eql 'not-passed coords-shapes)             nil coords-shapes)
		 ))))))

(defun overlay-merge-saves-use-uexpanded-table (saves &optional &key scalep (table-output-stream t) table-output-filename (if-exists-action :error))
  (let* ((saves (cons (car saves)
		      (mapcar (^ (slave-save)
				 (transform-slave-save-best-coords-by-procrustes-to-master-save-best-coordss-set-as-starting-coordss-in-new-save 
				  slave-save
				  (car saves)
				  :scalep scalep))
			      (cdr saves))))
	 (starting-coordss-s (mapcar #'starting-coordss-from-save saves))
	 (coordss-s          (mapcar #'coordss                    starting-coordss-s))
	 (col-bases-s        (mapcar #'col-bases                  starting-coordss-s))
	 (row-adjusts-s      (mapcar #'row-adjusts                starting-coordss-s))
	 (tables             (mapcar #'table-from-save            saves))
	 (unexpanded-merge-table  (unexpanded-hi-table-from-save (merge-tables (mapcar #'un-asl-hi-table tables)
									    :table-output-stream table-output-stream
									    :filename table-output-filename
									    :if-exists-action if-exists-action)))
	 (names-s            (mapcar #'hi-table-antigens          tables))
	 (merge-names        (hi-table-antigens-from-unexpanded-hi-table unexpanded-merge-table))
	 (merge-coordss (apply #'make-coordss-plus-more
			       (apply #'transpose
				      (loop for merge-name in merge-names collect
					    (let* ((positions (mapcar (^ (names) (position merge-name names)) names-s))
						   (coords-colbasis-rowadjust-triples
						    (loop for position in positions
							for coordss in coordss-s
							for col-bases in col-bases-s
							for row-adjusts in row-adjusts-s 
							when position
							collect (list (nth position coordss)
								      (nth position col-bases)
								      (nth position row-adjusts))))
						   (coords-av      (mapcar #'av (apply-transpose (nths 0 coords-colbasis-rowadjust-triples))))
						   (col-bases-max  (apply-max                    (nths 1 coords-colbasis-rowadjust-triples)))
						   (row-adjusts-av (av                           (nths 2 coords-colbasis-rowadjust-triples))))
					      (list coords-av col-bases-max row-adjusts-av))))))
	 (plot-spec-s (mapcar #'plot-spec-from-save saves))
	 (merge-plot-spec (loop for merge-name in merge-names
			      when (apply-append (mapcar (^ (plot-spec) (assoc merge-name plot-spec)) plot-spec-s))
			      collect (loop for plot-spec in plot-spec-s 
					  do (if (assoc merge-name plot-spec)
						 (return (assoc merge-name plot-spec)))
					  finally (error "unexpected case, sorry, please contact antigenic-cartography support")))))
    (make-save-form-from-unexpanded-hi-table
     :hi-table unexpanded-merge-table
     :starting-coordss merge-coordss
     :plot-spec merge-plot-spec
     :canvas-coord-transformations (canvas-coord-transformations-from-save (car saves))
     :reference-antigens (apply #'nary-union (mapcar #'reference-antigens-from-save saves))
     :raise-points       (apply #'nary-union (mapcar #'raise-points-from-save       saves))
     :lower-points       (apply #'nary-union (mapcar #'lower-points-from-save       saves)))))



;;;----------------------------------------------------------------------
;;;              subset save form without expanding table
;;;----------------------------------------------------------------------

(defun subset-coordss-with-unexpanded-tables (starting-coordss table table-extract)
  ;; table goes with the starting-coordss, the extract is the subset we want
  (new-starting-coords-matching-old-coordss
   starting-coordss
   (append 
    (mapcar #'suffix-as-ag (hi-table-antigens table))
    (mapcar #'suffix-as-sr (hi-table-sera table)))
   (append 
    (mapcar #'suffix-as-ag (hi-table-antigens table-extract))
    (mapcar #'suffix-as-sr (hi-table-sera table-extract)))
   :col-bases (collect-common 
	       (append 
                (mapcar #'suffix-as-ag (hi-table-antigens table))
                (mapcar #'suffix-as-sr (hi-table-sera table)))
	       (append 
                (mapcar #'suffix-as-ag (hi-table-antigens table-extract))
                (mapcar #'suffix-as-sr (hi-table-sera table-extract)))
	       :action-f (^ (position)
			    (if (null position)
				(error "expected the extract antigens to be in the original table")
			      (nth position (col-bases starting-coordss)))))))

(defun subset-save-form-by-excluding-without-expanding-table (save-form ag-and-sr-names)
  (subset-save-form-without-expanding-table
   save-form
   (reverse (set-difference (hi-table-antigens-table-from-save-non-expanding-hack save-form) ag-and-sr-names))))

(defun subset-save-form-without-expanding-table (save-form ag-and-sr-names &optional &key include-all-antigens include-all-sera)
  (let ((un-asl-hi-table (un-asl-hi-table-from-save save-form)))
    (if include-all-antigens (setq ag-and-sr-names (my-union (mapcar #'suffix-as-ag (hi-table-antigens un-asl-hi-table)) ag-and-sr-names)))
    (if include-all-sera     (setq ag-and-sr-names (my-union ag-and-sr-names (mapcar #'suffix-as-sr (hi-table-sera     un-asl-hi-table)))))
    (let ((starting-coordss (starting-coords-from-save save-form))
          (batch-runs (batch-runs-from-save save-form))
          (canvas-coord-transformations (canvas-coord-transformations-from-save save-form))
          (plot-spec (plot-spec-from-save save-form))
          (reference-antigens (reference-antigens-from-save save-form))
          (raise-points       (raise-points-from-save       save-form))
          (lower-points       (lower-points-from-save       save-form)))
      (let ((ag-names (mapcar #'remove-ag-sr-from-name (collect #'ag-name-p ag-and-sr-names)))
            (sr-names (mapcar #'remove-ag-sr-from-name (collect #'sr-name-p ag-and-sr-names))))
        (let* ((un-asl-hi-table-extract (extract-hi-table un-asl-hi-table ag-names sr-names))
               (coordss-extract (if starting-coordss (subset-coordss-with-unexpanded-tables starting-coordss un-asl-hi-table un-asl-hi-table-extract)))
               (batch-runs-extract (loop for (coordss stress unused1 unused2) in batch-runs 
                                       when (not (equal stress "Queued"))
                                       collect
                                         (list (subset-coordss-with-unexpanded-tables coordss un-asl-hi-table un-asl-hi-table-extract)
                                               stress unused1 unused2)))
               (plot-spec-subset (if plot-spec (plot-spec-subset plot-spec ag-and-sr-names)))
               (reference-antigens-subset (if reference-antigens 
                                              (my-intersection reference-antigens (mapcar #'remove-ag-sr-from-name (collect #'ag-name-p ag-and-sr-names)))))
               (raise-points-subset (if raise-points (my-intersection raise-points ag-and-sr-names)))
               (lower-points-subset (if lower-points (my-intersection lower-points ag-and-sr-names))))
          (apply #'make-save-form-from-unexpanded-hi-table
                 :hi-table (make-in-form un-asl-hi-table-extract)
                 (append (if coordss-extract (list :starting-coordss coordss-extract))
                         (if batch-runs-extract (list :batch-runs batch-runs-extract))
                         (if plot-spec-subset (list :plot-spec plot-spec-subset))
                         (if canvas-coord-transformations (list :canvas-coord-transformations canvas-coord-transformations))
                         (if reference-antigens-subset (list :reference-antigens reference-antigens-subset))
                         (if raise-points-subset       (list :raise-points       raise-points))
                         (if lower-points-subset       (list :lower-points       lower-points)))
                 ;; these would be good to extract from the same, but not implemented yet (2002-06-07)
                 ;;:mds-dimensions (get-mds-num-dimensions table-window)
                 ;;:coords-colors (multiple-nth point-indices (get-coords-colors table-window))
                 ;;:coords-dot-sizes (multiple-nth point-indices (get-coords-dot-sizes table-window))
                 ;;:coords-names (multiple-nth point-indices (get-coords-names table-window))
                 ;;:coords-names-working-copy (multiple-nth point-indices (get-coords-names-working-copy table-window))
                 ;;:coords-name-sizes (multiple-nth point-indices (get-coords-name-sizes table-window))
                 ;;:coords-name-colors (multiple-nth point-indices (get-coords-name-colors table-window))

                 ;; these two do not work, maybe not because of this, but maybe passing these in
                 ;;   to make-master-mds-window does not work (at lease we don't get the colors in tk
                 ;;   and we seem to get movement when we optimize
                 ;;:moveable-coords (let ((moveable-coords (get-moveable-coords table-window)))
                 ;;		  (if (eql 'all moveable-coords)
                 ;;		      moveable-coords
                 ;;		    (reverse (intersection moveable-coords point-indices))))
                 ;;:unmoveable-coords (reverse (intersection (get-unmoveable-coords table-window) point-indices))
                 ))))))


;;;----------------------------------------------------------------------
;;;                      
;;;----------------------------------------------------------------------

;;;----------------------------------------------------------------------
;;;                      "thin" table in save
;;;----------------------------------------------------------------------

(defun thin-table-in-save (proportion-to-keep save &optional &key (keep-diagonal t))
  (set-table-in-save 
   save
   (thin-table proportion-to-keep (table-from-save save) :keep-diagonal keep-diagonal)))



;;;----------------------------------------------------------------------
;;;                         anonymizer
;;;----------------------------------------------------------------------

(defun anonymize-save (save)
  (let ((table (un-asl-hi-table-from-save save)))
    (make-save-form 
     :hi-table (make-hi-table 
                (loop for i below (hi-table-length table) collect (read-from-string (format nil "ag-~d" i)))
                (loop for i below (hi-table-width  table) collect (read-from-string (format nil "sr-~d" i)))
                (hi-table-values table)))))
     



;;;----------------------------------------------------------------------
;;;                     automate row-adjusts
;;;                    (with Sam 18 Oct 2012)
;;;----------------------------------------------------------------------

(defun row-adjust-point (point-name save &optional &key 
                                                   (num-runs 100))
  (let* ((point-name-position (position point-name (hi-table-antigens (table-from-save save))))
         (adjusted-save (first-or-more-batch-mds-runs-from-save-return-save-iterate 
                         num-runs
                         save
                         :adjustable-rows (list point-name-position)
                         :moveable-coords (list point-name-position)
                         )))
    (values
     (nth point-name-position
          (row-adjusts 
           (starting-coords-from-save 
            adjusted-save)))
     adjusted-save)))

(defun row-adjust-ags-in-save (save &optional &key 
                                              (num-runs 100))
  (let ((ags (collect #'ag-name-p (hi-table-antigens (table-from-save save)))))
    (loop for ag in ags collect
          (list ag (row-adjust-point ag save :num-runs num-runs)))))



;;;----------------------------------------------------------------------
;;;                     automate col-adjusts
;;;                    (with Leah 19 Mar 2015)
;;;----------------------------------------------------------------------

(defun column-adjust-point (point-name save &optional &key 
                                                      (num-runs 100))
  (let* ((point-name-position (position point-name (hi-table-antigens (table-from-save save))))
         (adjusted-save (first-or-more-batch-mds-runs-from-save-return-save-iterate 
                         num-runs
                         save
                         :adjustable-columns (list point-name-position)
                         :moveable-coords    (list point-name-position)
                         )))
    (values
     (nth point-name-position
          (col-bases
           (starting-coords-from-save 
            adjusted-save)))
     adjusted-save)))

(defun column-adjust-srs-in-save (save &optional &key 
                                                 (num-runs 100))
  (let ((srs (collect #'sr-name-p (hi-table-antigens (table-from-save save)))))
    (loop for sr in srs collect
          (print (list sr (column-adjust-point sr save :num-runs num-runs))))))
