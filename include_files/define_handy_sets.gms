* Find out which segment carries out which fishery
* (=true if the number of gears and areas in which the segment carries out the fishery is >0)
segment_fishery(seg,f) = SUM((g,a) $ f_seg_g_a(f,seg,g,a), 1);


* Find out in which quota areas each fishery is active, useful in restrictions
quotaArea_fishery(quotaArea,f) = SUM((g,seg,a) $ (quotaArea_area(quotaArea,a) AND f_seg_g_a(f,seg,g,a)), 1);

* Define which species can be caught within a fishery, based on observed catch and by-catch
fishery_species(fishery,species) = YES $ p_catchOri(fishery,species);

fishery_area(fishery,area) = YES $ sum((seg,gear), f_seg_g_a(fishery,seg,gear,area));
fishery_gear(fishery,gear) = YES $ sum((seg,area), f_seg_g_a(fishery,seg,gear,area));


* Define which fisheries can use each catchQuota by looking it up in the mapping from excel
* (The indices are reversed in Excel for readability)
catchQuotaName_fishery(catchQuotaName,f) = fishery_catchQuotaName(f,catchQuotaName);

* Ange hur olika aggregat av fishery skapas utifrån individuella fishery,
* att använda i rapportering
fisheryDomain_fishery(segment,fishery)   = segment_fishery(segment,fishery);
fisheryDomain_fishery(quotaArea,fishery) = quotaArea_fishery(quotaArea,fishery);
fisheryDomain_fishery(gear,fishery) = SUM((seg,a) $ f_seg_g_a(fishery,seg,gear,a), 1);
fisheryDomain_fishery("total",fishery) = YES;

* Ange vilka fisken som levererar vilka arter under vilken kvot
catchQuotaName_fishery_species(catchQuotaName,f,s)
    $  [    catchQuotaName_fishery(catchQuotaName,f)
        AND catchQuotaName_species(catchQuotaName,s)
        AND fishery_species(f,s)]
    = YES;

catchQuotaName_quotaArea_fishery_species(catchQuotaName,quotaArea,f,s)
    $  [    quotaArea_fishery(quotaArea,f)
        AND catchQuotaName_fishery(catchQuotaName,f)
        AND catchQuotaName_species(catchQuotaName,s)
        AND fishery_species(f,s)]
    = YES;
