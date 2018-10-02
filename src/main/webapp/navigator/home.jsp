<%@ page import="edu.mcw.rgd.datamodel.ontologyx.Term" %>
<%@ page import="edu.mcw.rgd.datamodel.ontology.Annotation" %>
<%@ page import="edu.mcw.rgd.datamodel.Ortholog" %>
<%@ page import="edu.mcw.rgd.datamodel.Gene" %>
<%@ page import="com.google.gson.Gson" %>
<%@ page import="edu.mcw.rgd.datamodel.XdbId" %>
<%@ page import="edu.mcw.rgd.dao.impl.*" %>
<%@ page import="java.util.*" %>

<link rel="stylesheet" href="/navigator/common/bootstrap/css/bootstrap.css">

<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script>
<script src="/navigator/common/bootstrap/js/bootstrap.js"></script>
<link rel="stylesheet" href="/navigator/common/css/diseaseNavigator.css">

<script type="text/javascript" src="/navigator/common/angular/1.4.8/angular.js"></script>
<script type="text/javascript" src="/navigator/common/angular/1.4.8/angular-sanitize.js"></script>

<%
    String host = "http://localhost:8080";
%>

<script>

    var dmModule = angular.module('dmPage', ['ngSanitize']);

    dmModule.service('ConfigService', function () {

        this.listName="";
        this.listDescription="";
        this.geneWatchAttributes=["Nomenclature Changes","New GO Annotation","New Disease Annotation","New Phenotype Annotation","New Pathway Annotation","New PubMed Reference","Altered Strains","New NCBI Transcript/Protein","New Protein Interaction","RefSeq Status Has Changed"];
        this.username="Sign In";

    });

    dmModule.controller('DMController', [
        '$scope','$http',


        function ($scope, $http) {

            var ctrl = this;

            $scope.termAcc="<%=request.getParameter("accId")%>";
            $scope.genes = [];

            $scope.mgiMap={};
            $scope.hgncMap={} ;
            $scope.gtexMap=[];
            $scope.term = {};

            $scope.humanGenes=[];
            $scope.mouseGenes=[];
            $scope.ratGenes=[];

            $scope.annotatedGenes={};
            $scope.annotationMap={};

            $scope.allHuman=false;
            $scope.allMouse=false;
            $scope.allRat=false;

            $scope.grid=[$scope.humanGenes.length];

            ctrl.buildGrid2 = function() {

                 for (i = 0; i < $scope.humanGenes.length; i++) {

                 $scope.grid[i] = new Object();

                 $scope.grid[i].humanGene = $scope.humanGenes[i];
                 $scope.grid[i].humanGene.species = "Human";

                 if ($scope.annotationMap[$scope.grid[i].humanGene.rgdId]) {
                 $scope.grid[i].humanGene.styleClass = "orthoGeneBox";
                 } else {
                 $scope.grid[i].humanGene.styleClass = "geneBox";
                 }

                 $scope.grid[i].mouseGene = $scope.mouseGenes[i];
                 $scope.grid[i].mouseGene.species = "Mouse";

                 if ($scope.annotationMap[$scope.grid[i].mouseGene.rgdId]) {
                    $scope.grid[i].mouseGene.styleClass = "orthoGeneBox";
                 } else {
                    $scope.grid[i].mouseGene.styleClass = "geneBox";
                 }

                 $scope.grid[i].ratGene = $scope.ratGenes[i];
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
                        $scope.humanGenes[$scope.humanGenes.length] = gene;
                        $scope.grid[row].humanGene = gene;
                        $scope.grid[row].humanGene.species = "Human";
                        $scope.grid[row].humanGene.styleClass = "orthoGeneBox";
                    }else if (gene.speciesTypeKey == 2) {
                        $scope.mouseGenes[$scope.mouseGenes.length] = gene;
                        $scope.grid[row].mouseGene = gene;
                        $scope.grid[row].mouseGene.species = "Mouse";
                        $scope.grid[row].mouseGene.styleClass = "orthoGeneBox";

                    }else if (gene.speciesTypeKey == 3) {
                        $scope.ratGenes[$scope.ratGenes.length] = gene;
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
                            $scope.humanGenes[$scope.humanGenes.length] = ortho;
                            $scope.grid[row].humanGene = ortho;
                            $scope.grid[row].humanGene.species = "Human";

                            if ($scope.annotationMap[ortho.rgdId]) {
                                $scope.grid[row].humanGene.styleClass = "orthoGeneBox";
                            }else {
                                $scope.grid[row].humanGene.styleClass = "geneBox";
                            }

                        }else if (ortho.speciesTypeKey == 2) {
                            $scope.mouseGenes[$scope.mouseGenes.length] = ortho;
                            $scope.grid[row].mouseGene = ortho;
                            $scope.grid[row].mouseGene.species = "Mouse";

                            if ($scope.annotationMap[ortho.rgdId]) {
                                $scope.grid[row].mouseGene.styleClass = "orthoGeneBox";
                            }else {
                                $scope.grid[row].mouseGene.styleClass = "geneBox";
                            }


                        }else if (ortho.speciesTypeKey == 3) {
                            $scope.ratGenes[$scope.ratGenes.length] = ortho;
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


                    //if (i > 5) break;
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
                obj.evidenceCodes=['EXP','IAGP','IDA','IED','IEP','IGI','IMP','IPI','IPM','QTM'];

                $http({
                    method: 'POST',
                    url: "<%=host%>/rgdws/genes/annotation",
                    data: obj

                }).then(function successCallback(response) {
                    $scope.annotatedGenes = response.data;

                    for (i=0; i<$scope.annotatedGenes.length; i++) {
                        $scope.annotationMap[$scope.annotatedGenes[i].rgdId] = $scope.annotatedGenes[i];

                    }

                    //ctrl.initAnnotationMap();
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
                    url: "<%=host%>/rgdws/genes/orthologs",
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
                obj.rgdIds = [$scope.mouseGenes.length];
                for (i=0; i<$scope.mouseGenes.length; i++) {
                    obj.rgdIds[i] = $scope.mouseGenes[i].rgdId ;
                }

                $http({
                    method: 'POST',
                    url: "<%=host%>/rgdws/lookup/id/map/MGI",
                    data: obj

                }).then(function successCallback(response) {
                    $scope.mgiMap = response.data;

                }, function errorCallback(response) {
                    alert("ERRROR:" + response.data);
                });

            }

            ctrl.getGTEXMapping = function() {

                var obj = {};
                obj.rgdIds = [$scope.humanGenes.length];
                for (i=0; i<$scope.humanGenes.length; i++) {
                    obj.rgdIds[i] = $scope.humanGenes[i].rgdId ;
                }

                $http({
                    method: 'POST',
                    url: "<%=host%>/rgdws/lookup/id/map/GTEx",
                    data: obj

                }).then(function successCallback(response) {
                    $scope.gtexMap = response.data;

                }, function errorCallback(response) {
                    alert("ERRROR:" + response.data);
                });

            }

            ctrl.getHGNCMapping = function() {

                var obj = {};
                obj.rgdIds = [$scope.humanGenes.length];
                for (i=0; i<$scope.humanGenes.length; i++) {
                    obj.rgdIds[i] = $scope.humanGenes[i].rgdId ;
                }

                $http({
                    method: 'POST',
                    url: "<%=host%>/rgdws/lookup/id/map/HGNC",
                    data: obj

                }).then(function successCallback(response) {
                    $scope.hgncMap = response.data;

                }, function errorCallback(response) {
                    alert("ERRROR:" + response.data);
                });

            }


            ctrl.getTerm = function(termAcc) {

                $http({
                    method: 'GET',
                    url: "<%=host%>/rgdws/ontology/term/" + termAcc,

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
                for (var i = 0; i < $scope.genes.length; i++) {
                    if ($scope.genes[i].species == gene.species && $scope.genes[i].symbol == gene.symbol) {
                        this.deleteGene(i);
                    }
                }
            }

            ctrl.getGenesForSpeices = function (species) {
                var geneArray = [];
                for (var i = 0; i < $scope.genes.length; i++) {
                    if ($scope.genes[i].species == species) {
                        geneArray[geneArray.length] = $scope.genes[i];
                    }
                }
                return geneArray;
            }


            ctrl.navTopMed = function () {
                msg="<br>Not Implemented";

                $scope.modalTitle = "TopMed"
                $('#myModal').modal('show');

                document.getElementById("modalMsg").innerHTML = msg;

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
                    link = "http://www.informatics.jax.org/gxd/marker/" +  $scope.mgiMap[genes[i].primaryId];
                    //link = "https://www.gtexportal.org/home/gene/" + genes[i].symbol;
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


            ctrl.navGTEX = function () {

                var msg = "<br>More than one human gene has been selected.  Please select a gene from the list below to view the report at the GTex<br><br>";
                var link=""

                var genes = this.getGenesForSpeices("Human");
                if (genes.length==0) {
                    return;
                }

                msg += this.formatTableSymbol(genes, "https://www.gtexportal.org/home/gene/");

                /*
                for (var i=0; i<genes.length; i++) {
                        link = "https://www.gtexportal.org/home/gene/" + genes[i].symbol;
                        msg += "<a target='_blank' href='" + link + "'>" + genes[i].symbol + "</a><br>";
                }
                */

                if (genes.length == 1) {
                    link = "https://www.gtexportal.org/home/gene/" + genes[0].symbol;
                    window.open(link);
                    return;
                }

                $scope.modalTitle="GTex Expression";
                $('#myModal').modal('show');

                document.getElementById("modalMsg").innerHTML=msg;

            }

            ctrl.navAGRGene = function () {

                var msg = "<br>More than one human gene has been selected.  Please select a gene from the list below to view report at the Alliance of Genome Resources<br><br>";
                var link=""

                var genes = this.getGenesForSpeices("Human");
                if (genes.length==0) {
                    return;
                }

                msg += this.formatTableHGNC(genes, "http://www.alliancegenome.org/gene/");

                /*
                for (var i=0; i<genes.length; i++) {
                        link = "http://www.alliancegenome.org/gene/" + $scope.hgncMap[genes[i].primaryId];
                        msg += "<a target='_blank' href='" + link + "'>" + genes[i].symbol + "</a><br>";
                }
                */

                if (genes.length == 1) {
                    link = "http://www.alliancegenome.org/gene/" + $scope.hgncMap[genes[0].primaryId];
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

                msg += this.formatTable(genes, "http://www.informatics.jax.org/marker/");

                /*
                for (var i=0; i<genes.length; i++) {
                    link = "http://www.informatics.jax.org/marker/" + $scope.mgiMap[genes[i].primaryId];
                    msg += "<a target='_blank' href='" + link + "'>" + genes[i].symbol + "</a><br>";
                }
                */
                if (genes.length == 1) {
                    link = "http://www.informatics.jax.org/marker/" + $scope.mgiMap[genes[0].primaryId];
                    window.open(link);
                    return;
                }

                $scope.modalTitle="Mouse Genome Database: Gene Report"
                $('#myModal').modal('show');

                document.getElementById("modalMsg").innerHTML=msg;

            }

            ctrl.hgncGeneReport = function (){

                var msg = "<br>More than one human gene has been selected.  Please select a gene from the list below to view the report at HGNC<br><br>";
                var link=""

                var genes = this.getGenesForSpeices("Human");
                if (genes.length==0) {
                    return;
                }

                msg += this.formatTableHGNC(genes, "https://www.genenames.org/cgi-bin/gene_symbol_report?hgnc_id=");

                /*
                for (var i=0; i<genes.length; i++) {
                    link = "https://www.genenames.org/cgi-bin/gene_symbol_report?hgnc_id=" + $scope.hgncMap[genes[i].primaryId];
                    msg += "<a target='_blank' href='" + link + "'>" + genes[i].symbol + "</a><br>";
                }
                */

                if (genes.length == 1) {
                    link = "https://www.genenames.org/cgi-bin/gene_symbol_report?hgnc_id=" + $scope.hgncMap[genes[0].primaryId];
                    window.open(link);
                    return;
                }

                $scope.modalTitle="HGNC Gene Report"
                $('#myModal').modal('show');

                document.getElementById("modalMsg").innerHTML=msg;

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


                    link=url + genes[i].primaryId;
                    msg += "<div style='width:140px; font-size:18px; height:30px;'><a target='_blank' href='" + url +  $scope.hgncMap[genes[i].primaryId] + "'>" + genes[i].symbol + "</a></div>";

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

                /*
                for (var i=0; i<genes.length; i++) {
                        link="https://rgd.mcw.edu/rgdweb/report/gene/main.html?id=" +  genes[i].primaryId;
                        msg += "<a target='_blank' href='https://rgd.mcw.edu/rgdweb/report/gene/main.html?id=" +  genes[i].primaryId + "'>" + genes[i].symbol + "</a><br>";
                }
                */
                if (genes.length == 1) {
                    link="https://rgd.mcw.edu/rgdweb/report/gene/main.html?id=" +  genes[0].primaryId;
                    window.open(link);
                    return;
                }

                $scope.modalTitle="Rat Genome Database: Gene Report"
                $('#myModal').modal('show');

                //alert(msg);

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

                //if (genes.length > 500) {
                    alert(genes.length);
                //}


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
                        geneList = geneList + $scope.genes[i].symbol;
                    } else {
                        geneList = geneList + "," + $scope.genes[i].symbol;
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

                for (var i=0; i<$scope.genes.length; i++) {

                    if ($scope.genes[i].species == "Rat") {
                        foundRat=true;
                    }else if ($scope.genes[i].species == "Mouse") {
                        foundMouse=true;
                    }else if ($scope.genes[i].species == "Human") {
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

                obj.accId=termAcc;
                obj.speciesTypeKeys = [1,2,3];
                obj.evidenceCodes=['EXP','IAGP','IDA','IED','IEP','IGI','IMP','IPI','IPM','QTM'];

                $http({
                    method: 'POST',
                    url: "<%=host%>/rgdws/genes/annotation",
                    data: obj

                }).then(function successCallback(response) {
                    //$scope.annotatedGenes = response.data;
                    alert(response.data);
                    /*
                    for (i=0; i<$scope.annotatedGenes.length; i++) {
                        $scope.annotationMap[$scope.annotatedGenes[i].rgdId] = $scope.annotatedGenes[i];

                    }

                    ctrl.getOrthologs();
                    */
                }, function errorCallback(response) {
                    alert("ERRROR:" + response.data);
                });



                /*
                const rows = [["name1", "city1", "some other info"], ["name2", "city2", "more info"]];
                let csvContent = "data:text/csv;charset=utf-8,";
                rows.forEach(function(rowArray){
                    let row = rowArray.join(",");
                    csvContent += row + "\r\n";
                });
                */



                msg="<br>Not Implemented";

                $scope.modalTitle = "GTEx: Human Gene Expression"
                $('#myModal').modal('show');

                document.getElementById("modalMsg").innerHTML = msg;

            }



            ctrl.deleteGene = function(index) {
                var obj = $scope.genes[index];
                this.deselectGene(document.getElementById(obj.primaryId), obj.primaryId);
                $scope.genes.splice(index, 1);
            }


            ctrl.updateTools = function() {
                var foundHuman=false;
                var foundRat=false;
                var foundMouse=false;

                for (var i = 0; i < $scope.genes.length; i++) {
                    if ($scope.genes[i].species =='Human') {
                        foundHuman=true;
                    }
                    if ($scope.genes[i].species =='Rat') {
                        foundRat=true;
                    }
                    if ($scope.genes[i].species =='Mouse') {
                        foundMouse=true;
                    }

                }

                if (foundRat) {
                    var i=1;
                    var obj = document.getElementById("r" + i);
                    while (obj != null) {
                        obj.style.opacity=1;
                        //obj.style.display="block";
                        i++;
                        obj = document.getElementById("r" + i);

                    }
                }else {
                    var i=1;
                    var obj = document.getElementById("r" + i);
                    while (obj != null) {
                        obj.style.opacity=.5;
                        //obj.style.display="none";
                        i++;
                        obj = document.getElementById("r" + i);

                    }

                }
                if (foundMouse) {
                    var i=1;
                    var obj = document.getElementById("m" + i);
                    while (obj != null) {
                        obj.style.opacity=1;
                        //obj.style.display="block";
                        i++;
                        obj = document.getElementById("m" + i);

                    }
                }else {
                    var i=1;
                    var obj = document.getElementById("m" + i);
                    while (obj != null) {
                        obj.style.opacity=.5;
                        //obj.style.display="none";
                        i++;
                        obj = document.getElementById("m" + i);

                    }

                }
                if (foundHuman) {
                    var i=1;
                    var obj = document.getElementById("h" + i);
                    while (obj != null) {
                        obj.style.opacity=1;
                        //obj.style.display="block";
                        i++;
                        obj = document.getElementById("h" + i);

                    }
                }else {
                    var i=1;
                    var obj = document.getElementById("h" + i);
                    while (obj != null) {
                        obj.style.opacity=.5;
                        //obj.style.display="none";
                        i++;
                        obj = document.getElementById("h" + i);

                    }

                }
                if (foundHuman || foundRat || foundMouse) {
                    var i=1;
                    var obj = document.getElementById("a" + i);
                    while (obj != null) {
                        obj.style.opacity=1;
                        //obj.style.display="block";
                        i++;
                        obj = document.getElementById("a" + i);

                    }
                    ctrl.showMenu();
                }else {
                    var i=1;
                    var obj = document.getElementById("a" + i);
                    while (obj != null) {
                        obj.style.opacity=.5;
                        //obj.style.display="none";
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
                    if ($scope.allHuman) {
                        this.selectAllGenes(species);
                    }else {
                        this.deselectAllGenes(species);
                    }
                }
                if (species=="Mouse") {
                    if ($scope.allMouse) {
                        this.selectAllGenes(species);
                    }else {
                        this.deselectAllGenes(species);
                    }
                }
                if (species=="Rat") {
                    if ($scope.allRat) {
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
                    geneArray=$scope.humanGenes;
                }else if (species == "Mouse") {
                    geneArray=$scope.mouseGenes;
                }else if (species == "Rat") {
                    geneArray=$scope.ratGenes;
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
                    geneArray=$scope.humanGenes;
                }else if (species == "Mouse") {
                    geneArray=$scope.mouseGenes;
                }else if (species == "Rat") {
                    geneArray=$scope.ratGenes;
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
                    geneArray=$scope.humanGenes;
                }else if (species == "Mouse") {
                    geneArray=$scope.mouseGenes;
                }else if (species == "Rat") {
                    geneArray=$scope.ratGenes;
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
                for (var i=0; i< $scope.genes.length; i++) {
                    if ($scope.genes[i].primaryId == primaryId) {
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

                //var obj = $event.currentTarget;
                for (var i=0; i< $scope.genes.length; i++) {
                    if ($scope.genes[i].primaryId == primaryId) {

                        $scope.genes.splice(i, 1);

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

                if (obj==null) alert(symbol);

                obj.style.borderColor="#FEBE54";
                obj.style.backgroundColor="#B0A295";

                $scope.genes.push({'primaryId': primaryId, symbol: symbol, species: species})

                this.updateTools();
               // this.colorGenes();

            }

        }

    ]);
</script>


<div>

</div>




<body  ng-cloak ng-app="dmPage">

<div class="pageStyle" ng-controller="DMController as dm" id="DMController">




<div class="container">
    <!-- Modal -->
    <div class="modal fade" id="myModal" role="dialog">
        <div class="modal-dialog modal-lg">
            <div class="modal-content" id="rgd-modal">
                <div style="background-color:#2598C5; font-family:Arial; color:white; font-size:20px;padding:5px;">{{modalTitle}}</div>
            <table align="center" style="margin:10px;" border="0">
                <tr>
                    <td><div id="modalMsg"></div></td>
                </tr>
            </table>

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
<span style="background-color:#7395AE; color:#7395AE;height:10px;width:30px;border-radius:3px;margin-top:10px;margin-left:27px;">&nbsp;&nbsp;&nbsp;&nbsp;</span> Denotes Gene Annotated to <b>{{ term.term }}</b> - Orthology via <b>DIOPT</b>

    <br><br>


    <table cellspacing=0 cellpadding=0 border="0" style="margin-left:20px; padding-left:5px; border-bottom:2px solid #B1A296;">
        <tr>
            <td align="center" width="112"><div class="speciesHeader">Human<input ng-model="allHuman" ng-change="dm.selectAll($event,'Human')" type="checkbox"/></div></td>
            <td width="19">&nbsp;</td>
            <td align="center" width="112"><div class="speciesHeader">Mouse<input  ng-model="allMouse"  ng-change="dm.selectAll($event,'Mouse')"  type="checkbox"/></div></td>
            <td width="19">&nbsp;</td>
            <td align="center" width="112"><div class="speciesHeader">Rat<input  ng-model="allRat"  ng-change="dm.selectAll($event,'Rat')"  type="checkbox"/></div></td>
            <td width="70">&nbsp;</td>
            <td width="150" valign="top" class="speciesHeader">Genes Selected</td>
        </TR>
    </table>

    <table>
        <tr>
            <td valign="top">
                <table border="0" style="margin-left:20px;">

                    <tr ng-repeat="row in grid">
                        <td width="100">
                            <div id="{{row.humanGene.rgdId}}" class="{{row.humanGene.styleClass}}" ng-click="dm.select($event,row.humanGene.rgdId,row.humanGene.symbol,row.humanGene.species)">
                                <span ng-bind-html="row.humanGene.symbol"></span>
                            </div>
                        </td>
                        <td align="center" style="font-size:9px; color:#7395AE;" width="10">
                            --
                        </td>
                        <td width="100">
                            <div id="{{row.mouseGene.rgdId}}" class="{{row.mouseGene.styleClass}}" ng-click="dm.select($event,row.mouseGene.rgdId,row.mouseGene.symbol,row.mouseGene.species)">
                                <span ng-bind-html="row.mouseGene.symbol"></span>

                            </div>
                        </td>
                        <td align="center" style="font-size:9px; color:#7395AE;" width="10">
                            --
                        </td>
                        <td width="100">
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
                    <div class="selectedList" >

                        <div ng-repeat="gene in genes" style="border-bottom:1px solid black;padding-top:5px; padding-bottom:5px;vertical-align:top;">
                            <img ng-click="dm.removeGene(gene)" src="/navigator/common/images/del.jpg"/>&nbsp;&nbsp;&nbsp;&nbsp;<span ng-bind-html="gene.symbol"></span><span style="font-size:10px;">&nbsp;({{gene.species}})</span>
                        </div>
                    </div>
                </td>
                </table>
            </td>
        </tr>
    </table>

    <br><br><hr>



<div style="border:0px solid black; height:500px;overflow-y:scroll;padding-right:10px;">

    <div class="toolMenu" id="analysisMenu">

    <table border="0">
        <tr><td colspan="3" style="background-color:#2598C5; color:white;" class="diseaseTitle">Gene&nbsp;Set&nbsp;Analysis</td></tr>
        <tr><td>&nbsp;</td></tr>
        <tr>
            <td  colspan="3"><div class="toolMenuGroupTitle" >Gene Reports</div></td>
        </tr>
        <tr>
            <td>
                <div id="a3"  class="toolOption" ng-click="dm.navAGRGene()" ng-mouseover="dm.mouseOver($event)" ng-mouseleave="dm.mouseOut($event)">
                    <table>
                        <tr>
                            <td><img src="/navigator/common/images/alliance60.png" height="10" idth="100"/></td>
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
        </tr>
        <tr>
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
                            <td>GTEx<br>
                            </td>
                        </tr>
                    </table>
                </div>
            </td>
            <td>
                <div id="m2" class="toolOption" ng-click="dm.mgiExprReport()"  ng-mouseover="dm.mouseOver($event)" ng-mouseleave="dm.mouseOut($event)">
                    <table>
                        <tr >
                            <td><img ng-click="dm.mgiExprReport()" src="/navigator/common/images/mgi_logo.gif" height="10" idth="100"/></td>
                            <td>MGI</td>
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
                <div id="h2" class="toolOption" ng-click="dm.navTopMed()" ng-mouseover="dm.mouseOver($event)" ng-mouseleave="dm.mouseOut($event)">
                    <table>
                        <tr>
                            <td><img src="/navigator/common/images/dbGaP_logo.jpg" height="10" idth="10"/></td>
                            <td>TOPMed<br>
                            </td>
                        </tr>
                    </table>
                </div>

            </td>
            <td>
                <div id="r2" class="toolOption" ng-click="dm.navVV()" ng-mouseover="dm.mouseOver($event)" ng-mouseleave="dm.mouseOut($event)">
                    <table>
                        <tr>
                            <td><img ng-click="dm.navVV()" src="/navigator/common/images/polyphen.png" height="10" idth="100"/></td>
                            <td>Rat Strains</td>
                        </tr>
                    </table>
                </div>

            </td>
            <td>
                <div id="r3" class="toolOption" ng-click="dm.navVVDamaging()" ng-mouseover="dm.mouseOver($event)" ng-mouseleave="dm.mouseOut($event)">
                    <table>
                        <tr>
                            <td><img ng-click="dm.navVVDamaging()" src="/navigator/common/images/polyphen.png" height="10" idth="100"/></td>
                            <td>Rat (Polyphen)</td>
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
                <div id="r4" class="toolOption" ng-click="dm.navOlga()" ng-mouseover="dm.mouseOver($event)" ng-mouseleave="dm.mouseOut($event)">
                    <table>
                        <tr>
                            <td><img ng-click="dm.navOlga()" src="/navigator/common/images/olga60.png" height="10" idth="100"/></td>
                            <td>OLGA</td>
                        </tr>
                    </table>
                </div>
            </td>
            <td>
                <div id="r5" class="toolOption" ng-click="dm.navGA()" ng-mouseover="dm.mouseOver($event)" ng-mouseleave="dm.mouseOut($event)">
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
        <!--
        <tr>
            <td>
                <div id="a1" class="toolOption" ng-click="dm.navReferences()" ng-mouseover="dm.mouseOver($event)" ng-mouseleave="dm.mouseOut($event)">
                    <table>
                        <tr>
                            <td><img ng-click="dm.navReferences()" src="/navigator/common/images/pubmed.png" height="10" idth="100"/></td>
                            <td>References</td>
                        </tr>
                    </table>
                </div>

            </td>
        </tr>
        -->
    </table>


        <br>
        <br>
        <br>
        <br>
        <br>

        <div class="diseaseDescription2"><span style="font-size:16px; font-weight:700">{{ term.term }}</span><br>{{ term.definition }}</div>

</div>


</div>

</body>

<script>


</script>