%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% addDBNewGeneAnnotation
% Add changes from the database new anootation for new genes + manual curation on those changes
% Input: model, databasenewGPR.tsv,SGDgeneNames.tsv.
% As for the reference of new GPR, please find detailed information in:
% data/databases/DBnewGeneAnnotation.tsv
% NOTE: changeGeneAssociation.m is a function from cobra
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load model
cd ..
model = loadYeastModel;

% Change GPR relations
fid           = fopen('../data/modelCuration/databasenewGPR.tsv');
changegpr     = textscan(fid,'%s %s %s','Delimiter','\t','HeaderLines',1);
newGPR.ID     = changegpr{1};
newGPR.oldGPR = changegpr{2};
newGPR.GPR    = changegpr{3};
fclose(fid);
for i = 1:length(newGPR.ID)
    rxnIndex = find(strcmp(model.rxns, newGPR.ID(i)));
    model    = changeGrRules(model, model.rxns{rxnIndex}, newGPR.GPR{i});
end

% Delete unused genes (if any)
model = deleteUnusedGenes(model);
% Add gene standard name for new genes
fid = fopen('../data/databases/SGDgeneNames.tsv');
yeast_gene_annotation = textscan(fid,'%s %s','Delimiter','\t','HeaderLines',1);
fclose(fid);
for i = 1: length(model.genes)
    geneIndex = strcmp(yeast_gene_annotation{1}, model.genes{i});
    if sum(geneIndex) == 1 && ~isempty(yeast_gene_annotation{2}{geneIndex})
        model.geneShortNames{i} = yeast_gene_annotation{2}{geneIndex};
    else
        model.geneShortNames{i} = model.genes{i};
    end
end

saveYeastModel(model)
cd modelCuration
