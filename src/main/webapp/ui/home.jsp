<html>

<link rel="stylesheet" href="/navigator/common/bootstrap/css/bootstrap.css">
<link rel="stylesheet" href="/navigator/ui/navigator.css">

<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
<script src="/navigator/common/bootstrap/js/bootstrap.js"></script>
<script type="text/javascript" src="/navigator/common/angular/1.4.8/angular.js"></script>
<script type="text/javascript" src="/navigator/common/angular/1.4.8/angular-sanitize.js"></script>
<script type="text/javascript" src="/navigator/ui/navigator.js"></script>

<script>

    function getScope(ctrlName) {
        var sel = 'div[ng-controller="' + ctrlName + '"]';
        return angular.element(sel).scope();
    }

    function getUrlVars() {
        var vars = {};
        var parts = window.location.href.replace(/[?&]+([^=&]+)=([^&]*)/gi, function(m,key,value) {
            vars[key] = value;
        });
        return vars;
    }

    var dmModule = angular.module('dmPage', ['ngSanitize']);

    dmModule.controller('DMController', [
        '$scope','$http',

        function ($scope, $http) {

            var ctrl = this;

            $scope.serviceHost="https://rest.rgd.mcw.edu";
            $scope.termAcc=getUrlVars()["accId"];

            $scope.includedSpecies = ["Human","Mouse","Rat"];

            $scope.selectedGenes = [];
            $scope.term = {};

            //data structure for cross references
            $scope.xref= [];
            $scope.xref["mgi"] = {};
            $scope.xref["hgnc"] = {};
            $scope.xref["gtex"] = {};

            $scope.genes=[];
            for (var i in $scope.includedSpecies) {
                $scope.genes[$scope.includedSpecies[i]] = [];
            }

            $scope.annotatedGenes={};
            $scope.annotationMap={};

            //tracks the all selected control
            $scope.all=[];
            for (var species in $scope.includedSpecies) {
                $scope.all[$scope.includedSpecies[i]] = false;
            }

            $scope.grid=[$scope.genes["Human"].length];

            $scope.callbackFunction="";
            $scope.speciesSelected="";

            //list of evidence codes selected
            $scope.selectedEvidenceCodes=['EXP','IAGP','IDA','IED','IEP','IGI','IMP','IPI','IPM','QTM'];

            $scope.evidence={};
            $scope.evidence['EXP']=true;
            $scope.evidence['IAGP']=true;
            $scope.evidence['IDA']=true;
            $scope.evidence['IED']=true;
            $scope.evidence['IEP']=true;
            $scope.evidence['IGI']=true;
            $scope.evidence['IMP']=true;
            $scope.evidence['IPI']=true;
            $scope.evidence['IPM']=true;
            $scope.evidence['QTM']=true;
            $scope.evidence['ISS']=false;
            $scope.evidence['ISO']=false;

            //reset the application state
            ctrl.reset = function () {
                $scope.selectedGenes = [];

                $scope.xref["mgi"]={};
                $scope.xref["hgnc"]={} ;
                $scope.xref["gtex"]=[];

                $scope.term = {};

                for (var i in $scope.includedSpecies) {
                    $scope.genes[$scope.includedSpecies[i]] = [];
                }

                $scope.annotatedGenes={};
                $scope.annotationMap={};

                $scope.grid=new Array();
                $scope.grid=[$scope.genes["Human"].length];

                for (var species in $scope.includedSpecies) {
                    $scope.all[$scope.includedSpecies[i]] = false;
                }

                $scope.grid=new Array();

                $scope.callbackFunction="";
                $scope.speciesSelected="";

            }

            //evidence code control
            ctrl.selectEvidence = function ($event,evidence) {
                ctrl.reset();
                $scope.selectedEvidenceCodes=new Array();

                Object.keys($scope.evidence).forEach( function (key) {
                    if ($scope.evidence[key]) {
                        $scope.selectedEvidenceCodes.push(key);
                    }
                })

                ctrl.initialize();
            }

            ctrl.buildGrid2 = function() {

                for (i = 0; i < $scope.genes["Human"].length; i++) {

                    $scope.grid[i] = new Object();

                    $scope.grid[i].humanGene = $scope.genes["Human"][i];
                    $scope.grid[i].humanGene.species = "Human";

                    if ($scope.annotationMap[$scope.grid[i].humanGene.rgdId]) {
                        $scope.grid[i].humanGene.styleClass = "orthoGeneBox";
                    } else {
                        $scope.grid[i].humanGene.styleClass = "geneBox";
                    }

                    $scope.grid[i].mouseGene = $scope.genes["Mouse"][i];
                    $scope.grid[i].mouseGene.species = "Mouse";

                    if ($scope.annotationMap[$scope.grid[i].mouseGene.rgdId]) {
                        $scope.grid[i].mouseGene.styleClass = "orthoGeneBox";
                    } else {
                        $scope.grid[i].mouseGene.styleClass = "geneBox";
                    }

                    $scope.grid[i].ratGene = $scope.genes["Rat"][i];
                    $scope.grid[i].ratGene.species = "Rat";

                    if ($scope.annotationMap[$scope.grid[i].ratGene.rgdId]) {
                        $scope.grid[i].ratGene.styleClass = "orthoGeneBox";
                    } else {
                        $scope.grid[i].ratGene.styleClass = "geneBox";
                    }
                }

            }

            ctrl.buildGrid = function() {

                var seen = {};

                var row = 0;
                for (i = 0; i < $scope.annotatedGenes.length; i++) {
                    var gene = $scope.annotatedGenes[i];

                    if (seen[gene.rgdId]) {
                        continue;
                    }else {
                        seen[gene.rgdId] = 1;
                    }

                    $scope.grid[row] = new Object();

                    if (gene.speciesTypeKey == 1) {
                        $scope.genes["Human"][$scope.genes["Human"].length] = gene;
                        $scope.grid[row].humanGene = gene;
                        $scope.grid[row].humanGene.species = "Human";
                        $scope.grid[row].humanGene.styleClass = "orthoGeneBox";
                    }else if (gene.speciesTypeKey == 2) {
                        $scope.genes["Mouse"][$scope.genes["Mouse"].length] = gene;
                        $scope.grid[row].mouseGene = gene;
                        $scope.grid[row].mouseGene.species = "Mouse";
                        $scope.grid[row].mouseGene.styleClass = "orthoGeneBox";

                    }else if (gene.speciesTypeKey == 3) {
                        $scope.genes["Rat"][$scope.genes["Rat"].length] = gene;
                        $scope.grid[row].ratGene = gene;
                        $scope.grid[row].ratGene.species = "Rat";
                        $scope.grid[row].ratGene.styleClass = "orthoGeneBox";

                    }

                    for (i = 0; i < $scope.orthologMap[gene.rgdId].length; i++) {
                        var ortho = $scope.orthologMap[gene.rgdId][i];

                        if (seen[ortho.rgdId]) {
                            continue;
                        }else {
                            seen[ortho.rgdId] = 1;
                        }

                        if (ortho.speciesTypeKey == 1) {
                            $scope.genes["Human"][$scope.genes["Human"].length] = ortho;
                            $scope.grid[row].humanGene = ortho;
                            $scope.grid[row].humanGene.species = "Human";

                            if ($scope.annotationMap[ortho.rgdId]) {
                                $scope.grid[row].humanGene.styleClass = "orthoGeneBox";
                            }else {
                                $scope.grid[row].humanGene.styleClass = "geneBox";
                            }

                        }else if (ortho.speciesTypeKey == 2) {
                            $scope.genes["Mouse"][$scope.genes["Mouse"].length] = ortho;
                            $scope.grid[row].mouseGene = ortho;
                            $scope.grid[row].mouseGene.species = "Mouse";

                            if ($scope.annotationMap[ortho.rgdId]) {
                                $scope.grid[row].mouseGene.styleClass = "orthoGeneBox";
                            }else {
                                $scope.grid[row].mouseGene.styleClass = "geneBox";
                            }


                        }else if (ortho.speciesTypeKey == 3) {
                            $scope.genes["Rat"][$scope.genes["Rat"].length] = ortho;
                            $scope.grid[row].ratGene = ortho;
                            $scope.grid[row].ratGene.species = "Rat";

                            if ($scope.annotationMap[ortho.rgdId]) {
                                $scope.grid[row].ratGene.styleClass = "orthoGeneBox";
                            }else {
                                $scope.grid[row].ratGene.styleClass = "geneBox";
                            }

                        }

                    }

                    row++;

                }
                ctrl.getMGIMapping();
                ctrl.getHGNCMapping();
                ctrl.getGTEXMapping();
            }

            ctrl.getAnnotatedGenes = function(termAcc) {

                //get Annotated Genes
                var obj = {};

                obj.accId=termAcc;
                obj.speciesTypeKeys = [1,2,3];
                obj.evidenceCodes=$scope.selectedEvidenceCodes;

                $http({
                    method: 'POST',
                    url: $scope.serviceHost + "/rgdws/genes/annotation",
                    data: obj

                }).then(function successCallback(response) {
                    $scope.annotatedGenes = response.data;

                    for (i=0; i<$scope.annotatedGenes.length; i++) {
                        $scope.annotationMap[$scope.annotatedGenes[i].rgdId] = $scope.annotatedGenes[i];

                    }

                    ctrl.getOrthologs();

                }, function errorCallback(response) {
                    alert("ERRROR:" + response.data);
                });

            }


            ctrl.getAnnotations = function(termAcc) {

                //get Annotated Genes
                var obj = {};

                obj.accId=termAcc;
                obj.speciesTypeKeys = [1,2,3];
                obj.evidenceCodes=$scope.selectedEvidenceCodes;

                $http({
                    method: 'POST',
                    url: $scope.serviceHost + "/rgdws/genes/annotation",
                    data: obj

                }).then(function successCallback(response) {
                    $scope.annotatedGenes = response.data;

                    for (i=0; i<$scope.annotatedGenes.length; i++) {
                        $scope.annotationMap[$scope.annotatedGenes[i].rgdId] = $scope.annotatedGenes[i];

                    }

                    ctrl.getOrthologs();

                }, function errorCallback(response) {
                    alert("ERRROR:" + response.data);
                });

            }

            ctrl.getOrthologs = function() {
                //get Annotated Genes
                var obj = {};

                obj.rgdIds = [$scope.annotatedGenes.length];
                for (i=0; i<$scope.annotatedGenes.length; i++) {
                    obj.rgdIds[i] = $scope.annotatedGenes[i].rgdId ;
                }
                obj.speciesTypeKeys=[1,2,3];


                $http({
                    method: 'POST',
                    url: $scope.serviceHost + "/rgdws/genes/orthologs",
                    data: obj

                }).then(function successCallback(response) {

                    $scope.orthologMap = response.data;
                    ctrl.buildGrid();

                }, function errorCallback(response) {
                    alert("ERRROR:" + response.data);
                });

            }

            ctrl.getMGIMapping = function() {

                var obj = {};
                obj.rgdIds = [$scope.genes["Mouse"].length];
                for (i=0; i<$scope.genes["Mouse"].length; i++) {
                    obj.rgdIds[i] = $scope.genes["Mouse"][i].rgdId ;
                }

                $http({
                    method: 'POST',
                    url: $scope.serviceHost + "/rgdws/lookup/id/map/MGI",
                    data: obj

                }).then(function successCallback(response) {
                    //$scope.mgiMap = response.data;
                    $scope.xref["mgi"] = response.data;

                }, function errorCallback(response) {
                    alert("ERRROR:" + response.data);
                });

            }

            ctrl.getGTEXMapping = function() {

                var obj = {};
                obj.rgdIds = [$scope.genes["Human"].length];
                for (i=0; i<$scope.genes["Human"].length; i++) {
                    obj.rgdIds[i] = $scope.genes["Human"][i].rgdId ;
                }

                $http({
                    method: 'POST',
                    url: $scope.serviceHost + "/rgdws/lookup/id/map/GTEx",
                    data: obj

                }).then(function successCallback(response) {
                    $scope.xref["gtex"] = response.data;

                }, function errorCallback(response) {
                    alert("ERRROR:" + response.data);
                });

            }

            ctrl.getHGNCMapping = function() {

                var obj = {};
                obj.rgdIds = [$scope.genes["Human"].length];
                for (i=0; i<$scope.genes["Human"].length; i++) {
                    obj.rgdIds[i] = $scope.genes["Human"][i].rgdId ;
                }

                $http({
                    method: 'POST',
                    url: $scope.serviceHost + "/rgdws/lookup/id/map/HGNC",
                    data: obj

                }).then(function successCallback(response) {
                    $scope.xref["hgnc"] = response.data;

                }, function errorCallback(response) {
                    alert("ERRROR:" + response.data);
                });

            }


            ctrl.getTerm = function(termAcc) {

                $http({
                    method: 'GET',
                    url: $scope.serviceHost + "/rgdws/ontology/term/" + termAcc,

                }).then(function successCallback(response) {
                    $scope.term=response.data;

                }, function errorCallback(response) {
                    alert("ERRROR:" + response.data);
                });

            }



            ctrl.initialize = function() {

                ctrl.getAnnotatedGenes($scope.termAcc)
                ctrl.getTerm($scope.termAcc);


            }

            ctrl.initialize();

            ctrl.removeGene = function (gene) {
                for (var i = 0; i < $scope.selectedGenes.length; i++) {
                    if ($scope.selectedGenes[i].species == gene.species && $scope.selectedGenes[i].symbol == gene.symbol) {
                        this.deleteGene(i);
                    }
                }
            }

            ctrl.getGenesForSpeices = function (species) {
                var geneArray = [];
                for (var i = 0; i < $scope.selectedGenes.length; i++) {
                    if ($scope.selectedGenes[i].species == species) {
                        geneArray[geneArray.length] = $scope.selectedGenes[i];
                    }
                }
                return geneArray;
            }

            ctrl.navMgiExpression = function () {

                var msg = "<br>More than one mouse gene has been selected.  Please select a gene from the list below to view the report at the MGI<br><br>";
                var link=""

                var genes = this.getGenesForSpeices("Mouse");
                if (genes.length==0) {
                    return;
                }

                for (var i=0; i<genes.length; i++) {
                    link = "http://www.informatics.jax.org/gxd#gxd=nomenclature=" +  genes[i].symbol + "&vocabTerm=&annotationId=&locations=&locationUnit=bp&structure=&structureID=&theilerStage=0&results=100&startIndex=0&sort=&dir=asc&tab=resultstab";
                    msg += "<a target='_blank' href='" + link + "'>" + genes[i].symbol + "</a><br>";
                }

                if (genes.length == 1) {
                    window.open(link);
                    return;
                }

                $scope.modalTitle="MGI Mouse Expression";
                $('#myModal').modal('show');

                document.getElementById("modalMsg").innerHTML=msg;

            }


            ctrl.mgiExprReport = function () {

                var msg = "<br>More than one mouse gene has been selected.  Please select a gene from the list below to view the report at the GTEx<br><br>";
                var link=""

                var genes = this.getGenesForSpeices("Mouse");
                if (genes.length==0) {
                    return;
                }

                for (var i=0; i<genes.length; i++) {
                    link = "http://www.informatics.jax.org/gxd/marker/" +  $scope.xref["mgi"][genes[i].primaryId];
                    msg += "<a target='_blank' href='" + link + "'>" + genes[i].symbol + "</a><br>";
                }

                if (genes.length == 1) {
                    window.open(link);
                    return;
                }

                $scope.modalTitle="MGI Expression";
                $('#myModal').modal('show');

                document.getElementById("modalMsg").innerHTML=msg;

            }

            ctrl.navClinvar = function () {

                var msg = "<br>More than one human gene has been selected.  Please select a gene from the list below to view the report at the GTex<br><br>";
                var link=""

                var genes = this.getGenesForSpeices("Human");
                if (genes.length==0) {
                    return;
                }

                msg += this.formatTableClinvar(genes, "https://www.ncbi.nlm.nih.gov/clinvar/?term=");

                if (genes.length == 1) {
                    link = "https://www.ncbi.nlm.nih.gov/clinvar/?term=" + genes[0].symbol + "[gene]";
                    window.open(link);
                    return;
                }

                $scope.modalTitle="GTex Expression";
                $('#myModal').modal('show');

                document.getElementById("modalMsg").innerHTML=msg;

            }


            ctrl.navGTEXTable = function () {

                var msg = "<br>More than one human gene has been selected.  Please select a gene from the list below to view the report at the GTex<br><br>";
                var link=""

                var genes = this.getGenesForSpeices("Human");
                if (genes.length==0) {
                    return;
                }

                var geneString = "";
                for (var i=0; i<genes.length; i++) {
                    geneString += genes[i].symbol + ","
                }

                link = "https://www.gtexportal.org/home/gene/" + geneString;
                window.open(link);
                return;

                $scope.modalTitle="GTex Expression";
                $('#myModal').modal('show');

                document.getElementById("modalMsg").innerHTML=msg;

            }


            ctrl.navGTEX = function () {

                var msg = "<br>More than one human gene has been selected.  Please select a gene from the list below to view the report at the GTex<br><br>";
                var link=""

                var genes = this.getGenesForSpeices("Human");
                if (genes.length==0) {
                    return;
                }

                msg += this.formatTableSymbol(genes, "https://gtexportal.org/home/multiGeneQueryPage/");

                var geneString = "";
                for (var i=0; i<genes.length; i++) {
                    geneString += genes[i].symbol + ","
                }


                link = "https://gtexportal.org/home/multiGeneQueryPage/" + geneString;
                window.open(link);
                return;

                $scope.modalTitle="GTex Expression";
                $('#myModal').modal('show');

                document.getElementById("modalMsg").innerHTML=msg;

            }


            //figure out if we have more than one species selected
            ctrl.speciesSelection = function(callbackFunction) {

                document.getElementById("Human_div").style.display="none";
                document.getElementById("Mouse_div").style.display="none";
                document.getElementById("Rat_div").style.display="none";

                for (var i = 0; i < $scope.selectedGenes.length; i++) {
                    document.getElementById($scope.selectedGenes[i].species + "_div").style.display="block";
                }


                var first = $scope.selectedGenes[0].species;
                $scope.callbackFunction=callbackFunction;
                for (var i = 1; i < $scope.selectedGenes.length; i++) {
                    if ($scope.selectedGenes[i].species != first) {
                        $('#speciesModal').modal('show');
                        return;
                    }
                }
                $scope.speciesSelected=first;
                callbackFunction();
            }

            ctrl.selectSpecies = function (species) {
                $scope.speciesSelected=species;
                $('#speciesModal').modal('hide');

                $scope.callbackFunction();

            }

            ctrl.navAGRGene = function (reset) {

                if (reset==true) {
                    $scope.speciesSelected="";
                }

                if ($scope.speciesSelected == "") {
                    ctrl.speciesSelection(this.navAGRGene);
                    return;
                }

                var msg = "<br>More than one " + $scope.speciesSelected + " human gene has been selected.  Please select a gene from the list below to view report at the Alliance of Genome Resources<br><br>";
                var link=""

                var genes = ctrl.getGenesForSpeices($scope.speciesSelected);

                if (genes.length==0) {
                    return;
                }

                msg += ctrl.formatTableHGNC(genes, "http://www.alliancegenome.org/gene/");

                var id= $scope.xref["hgnc"][genes[0].primaryId];
                if ($scope.speciesSelected == "Mouse") {
                    //id=$scope.mgiMap[genes[0].primaryId];
                    id=$scope.xref["mgi"][genes[0].primaryId];
                }else if ($scope.speciesSelected == "Rat") {
                    id="RGD:" + genes[0].primaryId;
                }

                if (genes.length == 1) {
                    link = "http://www.alliancegenome.org/gene/" + id;
                    window.open(link);
                    return;
                }

                $scope.modalTitle="Alliance of Genome Resources: Gene Report"
                $('#myModal').modal('show');

                document.getElementById("modalMsg").innerHTML=msg;

            }


            ctrl.mgiGeneReport = function (){

                var msg = "<br>More than one Mouse Gene has been selected.  Please select a gene from the list below to view the report at MGI<br><br>";
                var link=""

                var genes = this.getGenesForSpeices("Mouse");
                if (genes.length==0) {
                    return;
                }

                msg += this.formatTableMGI(genes, "http://www.informatics.jax.org/marker/");

                if (genes.length == 1) {
                    link = "http://www.informatics.jax.org/marker/" + $scope.xref["mgi"][genes[0].primaryId];
                    window.open(link);
                    return;
                }

                $scope.modalTitle="Mouse Genome Database: Gene Report"
                $('#myModal').modal('show');

                document.getElementById("modalMsg").innerHTML=msg;

            }

            ctrl.hgncGeneReport = function (){


                $scope.speciesSelected="";
                var msg = "<br>More than one human gene has been selected.  Please select a gene from the list below to view the report at HGNC<br><br>";
                var link=""

                var genes = this.getGenesForSpeices("Human");
                if (genes.length==0) {
                    return;
                }

                msg += this.formatTableHGNC(genes, "https://www.genenames.org/cgi-bin/gene_symbol_report?hgnc_id=");

                if (genes.length == 1) {
                    link = "https://www.genenames.org/cgi-bin/gene_symbol_report?hgnc_id=" + $scope.xref["hgnc"][genes[0].primaryId];
                    window.open(link);
                    return;
                }

                $scope.modalTitle="HGNC Gene Report"
                $('#myModal').modal('show');

                document.getElementById("modalMsg").innerHTML=msg;

            }

            ctrl.formatTableClinvar = function(genes, url) {

                var msg = "";
                var modVal=10;

                if (genes.length > 10) {
                    modVal = Math.round(genes.length / 4);
                }

                msg += "<div style=' float:left;'>";
                for (var i=0; i<genes.length ; i++) {
                    link=url + genes[i].primaryId;
                    msg += "<div style='width:140px; font-size:18px; height:30px;'><a target='_blank' href='" + url +  genes[0].symbol + "[gene]" + "'>" + genes[i].symbol + "</a></div>";

                    if (i !=0 && i % modVal == 0) {
                        msg += "</div><div style='float:left;'>";
                    }

                }
                msg += "</div>";

                return msg;

            }

            ctrl.formatTableMGI = function(genes, url) {

                var msg = "";

                var modVal=10;

                if (genes.length > 10) {
                    modVal = Math.round(genes.length / 4);
                }


                msg += "<div style=' float:left;'>";
                for (var i=0; i<genes.length ; i++) {


                    link=url + genes[i].primaryId;
                    msg += "<div style='width:140px; font-size:18px; height:30px;'><a target='_blank' href='" + url +  $scope.xref["mgi"][genes[i].primaryId] + "'>" + genes[i].symbol + "</a></div>";

                    if (i !=0 && i % modVal == 0) {
                        msg += "</div><div style='float:left;'>";
                    }

                }
                msg += "</div>";

                return msg;

            }


            ctrl.formatTable = function(genes, url) {

                var msg = "";

                var modVal=10;

                if (genes.length > 10) {
                    modVal = Math.round(genes.length / 4);
                }


                msg += "<div style=' float:left;'>";
                for (var i=0; i<genes.length ; i++) {


                    link=url + genes[i].primaryId;
                    msg += "<div style='width:140px; font-size:18px; height:30px;'><a target='_blank' href='" + url +  genes[i].primaryId + "'>" + genes[i].symbol + "</a></div>";

                    if (i !=0 && i % modVal == 0) {
                        msg += "</div><div style='float:left;'>";
                    }

                }
                msg += "</div>";

                return msg;

            }

            ctrl.formatTableSymbol = function(genes, url) {

                var msg = "";

                var modVal=10;

                if (genes.length > 10) {
                    modVal = Math.round(genes.length / 4);
                }


                msg += "<div style=' float:left;'>";
                for (var i=0; i<genes.length ; i++) {


                    link=url + genes[i].primaryId;
                    msg += "<div style='width:140px; font-size:18px; height:30px;'><a target='_blank' href='" + url +  genes[i].symbol + "'>" + genes[i].symbol + "</a></div>";

                    if (i !=0 && i % modVal == 0) {
                        msg += "</div><div style='float:left;'>";
                    }

                }
                msg += "</div>";

                return msg;

            }

            ctrl.formatTableHGNC = function(genes, url) {

                var msg = "";

                var modVal=10;

                if (genes.length > 10) {
                    modVal = Math.round(genes.length / 4);
                }


                msg += "<div style=' float:left;'>";
                for (var i=0; i<genes.length ; i++) {

                    var id= $scope.xref["hgnc"][genes[i].primaryId];
                    if ($scope.speciesSelected == "Mouse") {
                        id=$scope.xref["mgi"][genes[i].primaryId];
                    }else if ($scope.speciesSelected == "Rat") {
                        id="RGD:" + genes[i].primaryId;
                    }

                    link=url + id;
                    msg += "<div style='width:140px; font-size:18px; height:30px;'><a target='_blank' href='" + url +  id + "'>" + genes[i].symbol + "</a></div>";

                    if (i !=0 && i % modVal == 0) {
                        msg += "</div><div style='float:left;'>";
                    }

                }
                msg += "</div>";

                return msg;

            }

            ctrl.rgdGeneReport = function (){

                var msg = "<br>More than one rat gene has been selected.  Please select a gene from the list below to view the report at RGD<br><br>";
                var link="";

                var genes = this.getGenesForSpeices("Rat");
                if (genes.length==0) {
                    return;
                }

                msg += this.formatTable(genes, "https://rgd.mcw.edu/rgdweb/report/gene/main.html?id=");

                if (genes.length == 1) {
                    link="https://rgd.mcw.edu/rgdweb/report/gene/main.html?id=" +  genes[0].primaryId;
                    window.open(link);
                    return;
                }

                $scope.modalTitle="Rat Genome Database: Gene Report"
                $('#myModal').modal('show');

                document.getElementById("modalMsg").innerHTML=msg;

            }

            ctrl.mouseOver = function($event) {
                $event.currentTarget.style.backgroundColor="#F8F6F0";
            }

            ctrl.mouseOut = function($event) {
                $event.currentTarget.style.backgroundColor="#C1C9D1";
            }

            ctrl.navVV = function (){

                var msg = "";
                var link=""
                var genes = this.getGenesForSpeices("Rat");

                if (genes.length==0) {
                    return;
                }

                link = "http://rgd.mcw.edu/rgdweb/front/variants.html?start=&stop=&chr=&geneStart=&geneStop=&geneList=" + this.listToCSV(genes) + "&mapKey=360&con=&probably=&possibly=&depthLowBound=8&depthHighBound=&excludePossibleError=true&sample1=all";
                window.open(link);
                return;

            }

            ctrl.navVVDamaging = function (){

                var msg = "";
                var link=""

                var genes = this.getGenesForSpeices("Rat");
                if (genes.length==0) {
                    return;
                }

                link = "http://rgd.mcw.edu/rgdweb/front/variants.html?start=&stop=&chr=&geneStart=&geneStop=&geneList=" + this.listToCSV(genes) + "&mapKey=360&con=&probably=true&possibly=true&depthLowBound=8&depthHighBound=&excludePossibleError=true&sample1=all";
                window.open(link);
                return;

            }

            ctrl.navOlga = function (){
                msg="<br>Not Implemented";

                $scope.modalTitle = "GTEx: Human Gene Expression"
                $('#myModal').modal('show');

                document.getElementById("modalMsg").innerHTML = msg;

            }

            ctrl.listToCSV = function (arr) {

                var geneList="";
                var count = 0;
                for (var i=0; i<arr.length; i++) {
                    if (count == 0) {
                        geneList = geneList + $scope.selectedGenes[i].symbol;
                    } else {
                        geneList = geneList + "," + $scope.selectedGenes[i].symbol;
                    }
                    count++;
                }
                return geneList;

            }

            ctrl.navGA = function (){

                //check to see if more than one species has been selected.
                var msg = "Multiple species selected.  Please select a species to submit gene list.";

                var count = 0;
                var gene = {};
                var link=""

                var ratGeneList = this.getGenesForSpeices("Rat");
                var mouseGeneList = this.getGenesForSpeices("Mouse");
                var humanGeneList = this.getGenesForSpeices("Human");

                var listCount=0;
                if (ratGeneList.length > 0) {
                    link = "/rgdweb/ga/ui.html?species=3&rgdId=&idType=&o=D&o=W&o=N&o=P&o=C&o=F&o=E&x=19&x=40&x=36&x=52&x=29&x=31&x=45&x=23&x=32&x=48&x=17&x=33&x=50&x=54&x=2&x=20&x=41&x=57&x=27&x=5&x=35&x=49&x=58&x=55&x=42&x=3&x=38&x=1&x=10&x=15&x=7&x=6&x=37&x=39&x=53&x=43&x=65&x=34&x=4&x=21&x=30&x=14&x=22&x=44&x=60&x=24&x=51&x=16&x=56&ortholog=1&ortholog=2&ortholog=4&ortholog=5&ortholog=6&ortholog=7&chr=1&start=&stop=&mapKey=360";
                    link += "&genes=" + this.listToCSV(ratGeneList);
                    msg += "<a target='_blank' href='" + link + "'>Rat</a><br>";
                    listCount++;
                }

                if (mouseGeneList.length > 0) {
                    link = "/rgdweb/ga/ui.html?species=2&rgdId=&idType=&o=D&o=W&o=N&o=P&o=C&o=F&o=E&x=19&x=40&x=36&x=52&x=29&x=31&x=45&x=23&x=32&x=48&x=17&x=33&x=50&x=54&x=2&x=20&x=41&x=57&x=27&x=5&x=35&x=49&x=58&x=55&x=42&x=3&x=38&x=1&x=10&x=15&x=7&x=6&x=37&x=39&x=53&x=43&x=65&x=34&x=4&x=21&x=30&x=14&x=22&x=44&x=60&x=24&x=51&x=16&x=56&ortholog=1&ortholog=2&ortholog=4&ortholog=5&ortholog=6&ortholog=7&chr=1&start=&stop=&mapKey=35";
                    link += "&genes=" + this.listToCSV(mouseGeneList);
                    msg += "<a target='_blank' href='" + link + "'>Mouse</a><br>";
                    listCount++;
                }

                if (humanGeneList.length > 0) {
                    link = "/rgdweb/ga/ui.html?species=1&rgdId=&idType=&o=D&o=W&o=N&o=P&o=C&o=F&o=E&x=19&x=40&x=36&x=52&x=29&x=31&x=45&x=23&x=32&x=48&x=17&x=33&x=50&x=54&x=2&x=20&x=41&x=57&x=27&x=5&x=35&x=49&x=58&x=55&x=42&x=3&x=38&x=1&x=10&x=15&x=7&x=6&x=37&x=39&x=53&x=43&x=65&x=34&x=4&x=21&x=30&x=14&x=22&x=44&x=60&x=24&x=51&x=16&x=56&ortholog=1&ortholog=2&ortholog=4&ortholog=5&ortholog=6&ortholog=7&chr=1&start=&stop=&mapKey=38";
                    link += "&genes=" + this.listToCSV(humanGeneList);
                    msg += "<a target='_blank' href='" + link + "'>Human</a><br>";
                    listCount++;
                }

                for (var i=0; i<$scope.selectedGenes.length; i++) {

                    if ($scope.selectedGenes[i].species == "Rat") {
                        foundRat=true;
                    }else if ($scope.selectedGenes[i].species == "Mouse") {
                        foundMouse=true;
                    }else if ($scope.selectedGenes[i].species == "Human") {
                        foundHuman=true;
                    }

                }

                if (listCount==1) {
                    window.open(link);
                    return;
                }

                $scope.modalTitle="Rat Genome Database: Gene Annotator"
                $('#myModal').modal('show');

                document.getElementById("modalMsg").innerHTML=msg;

            }

            ctrl.navReferences = function (){

                msg="<br>Not Implemented";

                $scope.modalTitle = "GTEx: Human Gene Expression"
                $('#myModal').modal('show');

                document.getElementById("modalMsg").innerHTML = msg;

            }

            ctrl.navDownload = function (){

                //get Annotated Genes
                var obj = {};

                obj.termAcc=$scope.termAcc;
                obj.speciesTypeKeys = [1,2,3];
                obj.evidenceCodes=$scope.selectedEvidenceCodes;
                obj.ids=[$scope.selectedGenes.length];

                for (var i=0; i< $scope.selectedGenes.length; i++)  {
                    obj.ids[i] = "" + $scope.selectedGenes[i].primaryId;
                }

                $http({
                    method: 'POST',
                    url: $scope.serviceHost + "/rgdws/annotations/",
                    data: obj

                }).then(function successCallback(response) {

                    var dump = "RGD ID,Object Symbol,Aspect,Evidence,Notes,Object Name,Qualifier,Species,Term,Term Accession,With Info\n";
                    for (var i=0; i< response.data.length; i++) {
                        var ln = response.data[i];
                        console.log(ln);
                        dump += ln.annotatedObjectRgdId + "," +
                                ln.objectSymbol + "," +
                                ln.aspect + "," +
                                ln.evidence + "," +
                                ln.notes + "," +
                                ln.objectName + "," +
                                ln.qualifier + "," +
                                ln.speciesTypeKey + "," +
                                ln.term + "," +
                                ln.termAcc + "," +
                                ln.withInfo + "\n";
                    }

                    var encodedUri = encodeURI( 'data:text/csv;charset=utf-8,' + dump);
                    var link = document.createElement("a");
                    link.setAttribute("href", encodedUri);
                    link.setAttribute("download", $scope.term.term + "_annotations.csv");
                    document.body.appendChild(link); // Required for FF

                    link.click();

                }, function errorCallback(response) {
                    alert("ERRROR:" + response.data);
                });

            }

            ctrl.deleteGene = function(index) {
                var obj = $scope.selectedGenes[index];
                this.deselectGene(document.getElementById(obj.primaryId), obj.primaryId);
            }

            ctrl.updateTools = function() {
                var foundHuman=false;
                var foundRat=false;
                var foundMouse=false;

                for (var i = 0; i < $scope.selectedGenes.length; i++) {
                    if ($scope.selectedGenes[i].species =='Human') {
                        foundHuman=true;
                    }
                    if ($scope.selectedGenes[i].species =='Rat') {
                        foundRat=true;
                    }
                    if ($scope.selectedGenes[i].species =='Mouse') {
                        foundMouse=true;
                    }

                }

                if (foundRat) {
                    var i=1;
                    var obj = document.getElementById("r" + i);
                    while (obj != null) {
                        obj.style.opacity=1;
                        i++;
                        obj = document.getElementById("r" + i);

                    }
                }else {
                    var i=1;
                    var obj = document.getElementById("r" + i);
                    while (obj != null) {
                        obj.style.opacity=.5;
                        i++;
                        obj = document.getElementById("r" + i);

                    }

                }
                if (foundMouse) {
                    var i=1;
                    var obj = document.getElementById("m" + i);
                    while (obj != null) {
                        obj.style.opacity=1;
                        i++;
                        obj = document.getElementById("m" + i);

                    }
                }else {
                    var i=1;
                    var obj = document.getElementById("m" + i);
                    while (obj != null) {
                        obj.style.opacity=.5;
                        i++;
                        obj = document.getElementById("m" + i);

                    }

                }
                if (foundHuman) {
                    var i=1;
                    var obj = document.getElementById("h" + i);
                    while (obj != null) {
                        obj.style.opacity=1;
                        i++;
                        obj = document.getElementById("h" + i);

                    }
                }else {
                    var i=1;
                    var obj = document.getElementById("h" + i);
                    while (obj != null) {
                        obj.style.opacity=.5;
                        i++;
                        obj = document.getElementById("h" + i);
                    }
                }
                if (foundHuman || foundRat || foundMouse) {
                    var i=1;
                    var obj = document.getElementById("a" + i);
                    while (obj != null) {
                        obj.style.opacity=1;
                        i++;
                        obj = document.getElementById("a" + i);
                    }
                    ctrl.showMenu();
                }else {
                    var i=1;
                    var obj = document.getElementById("a" + i);
                    while (obj != null) {
                        obj.style.opacity=.5;
                        i++;
                        obj = document.getElementById("a" + i);
                    }
                    ctrl.hideMenu();
                }
            }

            ctrl.hideMenu = function() {
                if (1) return;

                if (parseFloat(document.getElementById("analysisMenu").style.opacity) <= 0) {
                    return;
                }

                var id = setInterval (frame,35);
                function frame() {
                    var elem = document.getElementById("analysisMenu");

                    var opacity = elem.style.opacity;
                    if (!elem.style.opacity) {
                        var opacity = 1;
                    }

                    elem.style.opacity = (parseFloat(opacity) - .1);

                    if (parseFloat(elem.style.opacity) <=0) {
                        clearInterval(id);
                    }
                }
            }

            ctrl.showMenu = function() {
                if (1) return;

                if (parseFloat(document.getElementById("analysisMenu").style.opacity) >= 1) {
                    return;
                }

                var id = setInterval (frame,35);

                function frame() {
                    var elem = document.getElementById("analysisMenu");

                    var opacity = elem.style.opacity;
                    if (!elem.style.opacity) {
                        var opacity = 0;
                    }

                    elem.style.opacity = (parseFloat(opacity) + .1);

                    if (parseFloat(elem.style.opacity) >=1) {
                        clearInterval(id);
                    }
                }

            }

            ctrl.selectAll = function ($event,species) {
                if (species=="Human") {
                    if ($scope.all["Human"]) {
                        this.selectAllGenes(species);
                    }else {
                        this.deselectAllGenes(species);
                    }
                }
                if (species=="Mouse") {
                    if ($scope.all["Mouse"]) {
                        this.selectAllGenes(species);
                    }else {
                        this.deselectAllGenes(species);
                    }
                }
                if (species=="Rat") {
                    if ($scope.all["Rat"]) {
                        this.selectAllGenes(species);
                    }else {
                        this.deselectAllGenes(species);
                    }
                }

            }

            ctrl.selectAllGenes = function (species) {

                ctrl.deselectAllGenes(species);
                var geneArray =[];

                if (species == "Human") {
                    geneArray=$scope.genes["Human"];
                }else if (species == "Mouse") {
                    geneArray=$scope.genes["Mouse"];
                }else if (species == "Rat") {
                    geneArray=$scope.genes["Rat"];
                }

                var i=0;
                for (var i=0; i<geneArray.length; i++) {
                    var obj = geneArray[i];
                    var div = document.getElementById(obj.rgdId);

                    //need to fix this.  hypertension and mouse causes issue
                    if (div==null) {
                        //alert(obj.rgdId);
                        continue;
                    }

                    this.selectGene(div, obj.rgdId,obj.symbol,species);

                }
            }

            ctrl.deselectAllGenes = function (species) {

                var geneArray =[];

                if (species == "Human") {
                    geneArray=$scope.genes["Human"];
                }else if (species == "Mouse") {
                    geneArray=$scope.genes["Mouse"];
                }else if (species == "Rat") {
                    geneArray=$scope.genes["Rat"];
                }

                var i=0;
                for (var i=0; i<geneArray.length; i++) {
                    var obj = geneArray[i];
                    var div = document.getElementById(obj.rgdId);
                    this.deselectGene(div, obj.rgdId);
                }
            }

            ctrl.deSelectAllGenes = function ($event,species) {

                var geneArray =[];

                if (species == "Human") {
                    geneArray=$scope.genes["Human"];
                }else if (species == "Mouse") {
                    geneArray=$scope.genes["Mouse"];
                }else if (species == "Rat") {
                    geneArray=$scope.genes["Rat"];
                }

                var i=0;
                for (var i=0; i<geneArray.length; i++) {
                    var obj = geneArray[i];
                    var div = document.getElementById(obj.rgdId);
                    this.selectGene(div, obj.rgdId,obj.symbol,species);
                }

            }

            ctrl.select = function ($event,primaryId, symbol, species)
            {
                //if already selected, deselect
                var obj = $event.currentTarget;
                //see if gene is already in the list
                found=false;
                for (var i=0; i< $scope.selectedGenes.length; i++) {
                    if ($scope.selectedGenes[i].primaryId == primaryId) {
                        found=true;
                    }
                }

                if (found) {
                    this.deselectGene($event.currentTarget, primaryId);
                }else {
                    this.selectGene($event.currentTarget, primaryId, symbol, species);
                }

            }

            ctrl.deselectGene = function (obj,primaryId) {

                for (var i=0; i< $scope.selectedGenes.length; i++) {
                    if ($scope.selectedGenes[i].primaryId == primaryId) {

                        $scope.selectedGenes.splice(i, 1);

                        if ($scope.annotationMap[primaryId]) {
                            obj.style.borderColor="#557A95";
                            obj.style.backgroundColor="#7395AE";
                        }else {
                            obj.style.backgroundColor="white";
                            obj.style.borderColor="#7395AE";
                        }

                        this.updateTools();
                        return;
                    }
                }
            }

            ctrl.selectGene = function (obj, primaryId, symbol, species) {
                obj.style.borderColor="#FEBE54";
                obj.style.backgroundColor="#B0A295";

                $scope.selectedGenes.push({'primaryId': primaryId, symbol: symbol, species: species})

                this.updateTools();
            }
        }
    ]);
</script>


<body  ng-cloak ng-app="dmPage">

<div class="pageStyle" ng-controller="DMController as dm" id="DMController">
<div class="container">
    <!-- Modal -->
    <div class="modal fade" id="myModal" role="dialog">
        <div class="modal-dialog modal-lg">
            <div class="modal-content" id="rgd-modal">
                <div class="modalTitle">{{modalTitle}}</div>
            <table align="center" style="margin:10px;" border="0">
                <tr>
                    <td><div id="modalMsg"></div></td>
                </tr>
                <tr>
                    <td align="right">
                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                    </td>
                </tr>
            </table>
            </div>
        </div>
    </div>
</div>


    <script>
        $('#speciesModal').on('hidden', function () {
            //alert("hey");
        })
    </script>


    <div class="container">
        <!-- Modal -->
        <div class="modal fade" id="speciesModal" role="dialog">
            <div class="modal-dialog modal-lg">
                <div class="modal-content" id="rgd-species-modal">
                    <div class="modalTitle" >Select a species</div>
                    <br>&nbsp;&nbsp;You have more than one species selected.  Please select a species to continue<br><br>
                        <div class="speciesButton" id="Human_div" ><button class="btn btn-primary" ng-click="dm.selectSpecies('Human')">Human</button></div>
                        <div class="speciesButton" id="Mouse_div" ><button type="button" ng-click="dm.selectSpecies('Mouse')" class="btn btn-primary">Mouse</button></div>
                        <div class="speciesButton" id="Rat_div" ><button class="btn btn-primary" ng-click="dm.selectSpecies('Rat')">Rat</button></div>

                    </table>
                    <br>
                    <br>
                    <br>

                </div>
            </div>
        </div>
    </div>

<div class="pageTitleBar">
    <table border="0" width="95%">
        <tr>
            <td width="80"><img src="/navigator/common/images/diseaseNavLogo75.png"/></td>
            <td class="pageTitle" width="280">Alliance<br>Disease<br>Navigator</td>
            <td>&nbsp;</td>

            <td width="80"><img src="/navigator/common/images/logo_mgi.png"/></td>
            <td width="80"><img src="/navigator/common/images/logo_rgd.png"/></td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>

        </tr>
    </table>

</div>

<div class="diseaseTitle">{{term.term}}</div>
    <br>
    <span class="diseaseSubTitle">&nbsp;&nbsp;&nbsp;&nbsp;</span> Denotes Gene Annotated to <b>{{ term.term }}</b> - Orthology via <b>DIOPT</b>

    <div class="evidenceSelector"><span style="font-weight:700;">Evidence:</span>
        <input ng-model="evidence['EXP']" ng-change="dm.selectEvidence($event)" type="checkbox"/>EXP
        <input ng-model="evidence['IAGP']" ng-change="dm.selectEvidence($event)" type="checkbox"/>IAGP
        <input ng-model="evidence['IDA']" ng-change="dm.selectEvidence($event)" type="checkbox"/>IDA
        <input ng-model="evidence['IED']" ng-change="dm.selectEvidence($event)" type="checkbox"/>IED
        <input ng-model="evidence['IEP']" ng-change="dm.selectEvidence($event)" type="checkbox"/>IEP
        <input ng-model="evidence['IGI']" ng-change="dm.selectEvidence($event)" type="checkbox"/>IGI
        <input ng-model="evidence['IMP']" ng-change="dm.selectEvidence($event)" type="checkbox"/>IMP
        <input ng-model="evidence['IPI']" ng-change="dm.selectEvidence($event)" type="checkbox"/>IPI
        <input ng-model="evidence['IPM']" ng-change="dm.selectEvidence($event)" type="checkbox"/>IPM
        <input ng-model="evidence['QTM']" ng-change="dm.selectEvidence($event)" type="checkbox"/>QTM
        <input ng-model="evidence['ISS']" ng-change="dm.selectEvidence($event)" type="checkbox"/>ISS
        <input ng-model="evidence['ISO']" ng-change="dm.selectEvidence($event)" type="checkbox"/>ISO
    </div>

    <table cellspacing=0 cellpadding=0 border="0" class="speciesSelector">
        <tr>
            <td align="center" width="112"><div class="speciesHeader">Human<input ng-model="all['Human']" ng-change="dm.selectAll($event,'Human')" type="checkbox"/></div></td>
            <td width="19">&nbsp;</td>
            <td align="center" width="112"><div class="speciesHeader">Mouse<input  ng-model="all['Mouse']"  ng-change="dm.selectAll($event,'Mouse')"  type="checkbox"/></div></td>
            <td width="19">&nbsp;</td>
            <td align="center" width="112"><div class="speciesHeader">Rat<input  ng-model="all['Rat']"  ng-change="dm.selectAll($event,'Rat')"  type="checkbox"/></div></td>
            <td width="80">&nbsp;</td>
            <td width="150" valign="top" class="speciesHeader">Genes Selected</td>
        </TR>
    </table>

    <table>
        <tr>
            <td valign="top">
                <table border="0" style="margin-left:20px;">

                    <tr ng-repeat="row in grid">
                        <td width="110">
                            <div id="{{row.humanGene.rgdId}}" class="{{row.humanGene.styleClass}}" ng-click="dm.select($event,row.humanGene.rgdId,row.humanGene.symbol,row.humanGene.species)">
                                <span ng-bind-html="row.humanGene.symbol"></span>
                            </div>
                        </td>
                        <td align="center" class="geneTableSpacer" width="10">
                            --
                        </td>
                        <td width="110">
                            <div id="{{row.mouseGene.rgdId}}" class="{{row.mouseGene.styleClass}}" ng-click="dm.select($event,row.mouseGene.rgdId,row.mouseGene.symbol,row.mouseGene.species)">
                                <span ng-bind-html="row.mouseGene.symbol"></span>

                            </div>
                        </td>
                        <td align="center" class="geneTableSpacer" width="10">
                            --
                        </td>
                        <td width="110">
                            <div id="{{row.ratGene.rgdId}}" class="{{row.ratGene.styleClass}}" ng-click="dm.select($event,row.ratGene.rgdId,row.ratGene.symbol,row.ratGene.species)">
                                <span ng-bind-html="row.ratGene.symbol"></span>
                            </div>
                        </td>

                    </tr>
                </table>

            </td>
            <td valign="top">
                <table >
                <td width="30"><img src="/navigator/common/images/red-arrow-small.png"/></td>
                <td width="175"  valign="top">
                    <div class="geneSelectedList" >

                        <div ng-repeat="gene in selectedGenes" class="geneSelectedListItem" >
                            <img ng-click="dm.removeGene(gene)" src="/navigator/common/images/del.jpg"/>&nbsp;&nbsp;&nbsp;&nbsp;<span ng-bind-html="gene.symbol"></span><span style="font-size:10px;">&nbsp;({{gene.species}})</span>
                        </div>
                    </div>
                </td>
                </table>
            </td>
        </tr>
    </table>

    <br><br><hr>

<div class="analysisMenu">

    <div class="toolMenu" id="analysisMenu">

    <table border="0">
        <tr><td colspan="3" class="analysisMenuTitle">Gene&nbsp;Set&nbsp;Analysis</td></tr>
        <tr><td>&nbsp;</td></tr>
        <tr>
            <td colspan="3"><div class="toolMenuGroupTitle" >Gene Reports</div></td>
        </tr>
        <tr>
            <td>
                <div id="a1"  class="toolOption" ng-click="dm.navAGRGene(true)" ng-mouseover="dm.mouseOver($event)" ng-mouseleave="dm.mouseOut($event)">
                    <table>
                        <tr>
                            <td><img src="/navigator/common/images/alliance60.png" height="10" /></td>
                            <td>Alliance<br>
                            </td>
                        </tr>
                    </table>
                </div>

            </td>
            <td>
                <div id="m1" class="toolOption" ng-click="dm.mgiGeneReport()"  ng-mouseover="dm.mouseOver($event)" ng-mouseleave="dm.mouseOut($event)">
                    <table>
                        <tr >
                            <td><img ng-click="dm.mgiGeneReport()" src="/navigator/common/images/mgi_logo.gif" height="10" idth="100"/></td>
                            <td>MGI</td>
                        </tr>
                    </table>
                </div>

            </td>
        </tr>
        <tr>
            <td>
                <div id="r1" class="toolOption" ng-click="dm.rgdGeneReport()"  ng-mouseover="dm.mouseOver($event)" ng-mouseleave="dm.mouseOut($event)">
                    <table>
                        <tr>
                            <td><img ng-click="dm.rgdGeneReport()" src="/navigator/common/images/rgd_logo60.png" height="10" idth="100"/></td>
                            <td>RGD</td>
                        </tr>
                    </table>
                </div>
            </td>
            <td>
                <div id="h3" class="toolOption" ng-click="dm.hgncGeneReport()"  ng-mouseover="dm.mouseOver($event)" ng-mouseleave="dm.mouseOut($event)">
                    <table>
                        <tr>
                            <td><img ng-click="dm.hgncGeneReport()" src="/navigator/common/images/hgnc.png" height="10" idth="100"/></td>
                            <td>HGNC</td>
                        </tr>
                    </table>
                </div>
            </td>
        </tr>
        <tr>
            <td colspan="3"><div class="toolMenuGroupTitle" >Expression</div></td>
        </tr>
            <td>
                <div id="h1" class="toolOption" ng-click="dm.navGTEX()" ng-mouseover="dm.mouseOver($event)" ng-mouseleave="dm.mouseOut($event)">
                    <table>
                        <tr>
                            <td><img src="/navigator/common/images/gtex.png" height="10" idth="10"/></td>
                            <td>GTEx Multi Gene<br>
                            </td>
                        </tr>
                    </table>
                </div>
            </td>
        <td>
            <div id="h2" class="toolOption" ng-click="dm.navGTEXTable()" ng-mouseover="dm.mouseOver($event)" ng-mouseleave="dm.mouseOut($event)">
                <table>
                    <tr>
                        <td><img src="/navigator/common/images/gtex.png" height="10" idth="10"/></td>
                        <td>GTEx Report<br>
                        </td>
                    </tr>
                </table>
            </div>
        </td>
    </tr><tr>
            <td>
                <div id="m2" class="toolOption" ng-click="dm.mgiExprReport()"  ng-mouseover="dm.mouseOver($event)" ng-mouseleave="dm.mouseOut($event)">
                    <table>
                        <tr >
                            <td><img ng-click="dm.mgiExprReport()" src="/navigator/common/images/mgi_logo.gif" height="10" idth="100"/></td>
                            <td>MGI Expression</td>
                        </tr>
                    </table>
                </div>

            </td>
        </tr>
        <tr>
            <td colspan="3"><div class="toolMenuGroupTitle" >Variants</div></td>
        </tr>
        <tr>
            <td>
                <div id="h4" class="toolOption" ng-click="dm.navClinvar()" ng-mouseover="dm.mouseOver($event)" ng-mouseleave="dm.mouseOut($event)">
                    <table>
                        <tr>
                            <td><img src="/navigator/common/images/dbGaP_logo.jpg" height="10" idth="10"/></td>
                            <td>ClinVar<br>
                            </td>
                        </tr>
                    </table>
                </div>

            </td>
            <td>
                <div id="r2" class="toolOption" ng-click="dm.navVV()" ng-mouseover="dm.mouseOver($event)" ng-mouseleave="dm.mouseOut($event)">
                    <table>
                        <tr>
                            <td><img ng-click="dm.navVV()" src="/navigator/common/images/rgd_logo60.png" height="10" idth="100"/></td>
                            <td>Rat Strains</td>
                        </tr>
                    </table>
                </div>

            </td>
            </tr><tr>
            <td>
                <div id="r3" class="toolOption" ng-click="dm.navVVDamaging()" ng-mouseover="dm.mouseOver($event)" ng-mouseleave="dm.mouseOut($event)">
                    <table>
                        <tr>
                            <td><img ng-click="dm.navVVDamaging()" src="/navigator/common/images/polyphen.png" height="10" idth="100"/></td>
                            <td>Rat<br>(Polyphen)</td>
                        </tr>
                    </table>
                </div>

            </td>
        </tr>
        <tr>
            <td colspan="3"><div class="toolMenuGroupTitle" >Additional&nbsp;Analysis</div></td>
        </tr>
        <tr>
            <td>
                <div id="r4" class="toolOption" ng-click="dm.navGA()" ng-mouseover="dm.mouseOver($event)" ng-mouseleave="dm.mouseOut($event)">
                    <table>
                        <tr>
                            <td><img ng-click="dm.navGA()" src="/navigator/common/images/gaTool60.png" height="10" idth="100"/></td>
                            <td>Gene Annotator</td>
                        </tr>
                    </table>
                </div>
            </td>
            <td>
                <div id="a2" class="toolOption" ng-click="dm.navDownload()" ng-mouseover="dm.mouseOver($event)" ng-mouseleave="dm.mouseOut($event)">
                    <table>
                        <tr>
                            <td><img ng-click="dm.navDownload()" src="/navigator/common/images/excel60.png" height="10" idth="100"/></td>
                            <td>Download Annotations</td>
                        </tr>
                    </table>
                </div>

            </td>

        </tr>
    </table>

        <br>
        <br>
        <br>
        <br>
        <br>

        <div class="termDescription"><span class="termTitle">{{ term.term }}</span><br>{{ term.definition }}</div>

</div>


</div>

</body>




</html>