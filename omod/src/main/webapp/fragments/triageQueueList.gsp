<% if (currentLocation?.uuid?.equals(triageLocation)) { %>
<%
        ui.includeCss("coreapps", "patientsearch/patientSearchWidget.css")
        ui.includeJavascript("patientqueueing", "patientqueue.js")
        ui.includeJavascript("aijar", "js/aijar.js")
%>
<style>
.card-body {
    -ms-flex: 1 1 auto;
    flex: 7 1 auto;
    padding: 1.0rem;
    background-color: #eee;
}

.vertical {
    border-left: 1px solid #c7c5c5;
    height: 79px;
    position: absolute;
    left: 99%;
    top: 11%;
}
</style>
<script>
    var stillInQueue = 0;
    var completedQueue = 0;
    jq(document).ready(function () {
        jq("#tabs").tabs();
    })
    if (jQuery) {
        /*setInterval(function () {
            console.log("Checking IF Reloading works");
            getPatientQueue();
        }, 3000);*/
        jq(document).ready(function () {
            jq(document).on('sessionLocationChanged', function () {
                window.location.reload();
            });
            jq("#clinician-list").hide();
            getPatientQueue();
            jq("#patient-triage-search").change(function () {
                if (jq("#patient-triage-search").val().length >= 3) {
                    getPatientQueue();
                }
            });

            jq('#pick_patient_queue_dialog').on('show.bs.modal', function (event) {
                var button = jq(event.relatedTarget)
                jq("#patientQueueId").val(button.data('patientqueueid'));
                jq("#goToURL").val(button.data('url'));
            })
        });
    }
    jq("form").submit(function (event) {
        alert("Handler for .submit() called.");
    });

    //GENERATION OF LISTS IN INTERFACE SUCH AS WORKLIST
    // Get Patients In Triage Queue
    function getPatientQueue() {
        jq("#triage-queue-list-table").html("");
        jq.get('${ ui.actionLink("getPatientQueueList") }', {
            triageSearchFilter: jq("#patient-triage-search").val().trim().toLowerCase()
        }, function (response) {
            if (response) {
                var responseData = JSON.parse(response.replace("patientTriageQueueList=", "\"patientTriageQueueList\":").trim());
                displayTriageData(responseData);
            } else if (!response) {
                jq("#triage-queue-list-table").append(${ ui.message("coreapps.none ") });
            }
        });
    }

    function displayTriageData(response) {
        jq("#triage-queue-list-table").html("");
        var stillInQueueDataRows = "";
        var completedDataRows = "";
        stillInQueue = 0;
        completedQueue = 0;
        var headerPending = "<table><thead><tr><th>VISIT ID</th><th>NAMES</th><th>GENDER</th><th>AGE</th><th>VISIT STATUS</th><th>ENTRY POINT</th><th>WAITING TIME</th><th>ACTION</th></tr></thead><tbody>";
        var headerCompleted = "<table><thead><tr><th>VISIT ID</th><th>NAMES</th><th>GENDER</th><th>AGE</th><th>ENTRY POINT</th><th>COMPLETED TIME</th><th>ACTION</th></tr></thead><tbody>";
        var footer = "</tbody></table>";

        var dataToDisplay = [];

        if (response.patientTriageQueueList.length > 0) {
            dataToDisplay = response.patientTriageQueueList.sort(function (a, b) {
                return a.patientQueueId - b.patientQueueId;
            });
        }

        jq.each(dataToDisplay, function (index, element) {
                var patientQueueListElement = element;
                var dataRowTable = "";
                var vitalsPageLocation = "";
                if (element.status !== "COMPLETED") {
                    vitalsPageLocation = "/" + OPENMRS_CONTEXT_PATH + "/htmlformentryui/htmlform/enterHtmlFormWithStandardUi.page?patientId=" + patientQueueListElement.patientId + "&visitId=" + patientQueueListElement.visitId + "&formUuid=d514be1d-8a95-4f46-b8d8-9b8485679f47&returnUrl=" + "/" + OPENMRS_CONTEXT_PATH + "/patientqueueing/providerDashboard.page";
                } else if (element.status !== "COMPLETED" && (element.encounterId !== null || element.encounterId !== "")) {
                    vitalsPageLocation = "/" + OPENMRS_CONTEXT_PATH + "/htmlformentryui/htmlform/editHtmlFormWithStandardUi.page?patientId=" + patientQueueListElement.patientId + "&formUuid=d514be1d-8a95-4f46-b8d8-9b8485679f47&encounterId=" + patientQueueListElement.encounterId + "&visitId=" + patientQueueListElement.visitId + "&returnUrl=" + "/" + OPENMRS_CONTEXT_PATH + "/patientqueueing/providerDashboard.page";
                    ;
                }

                var action = "";

                if ("${enablePatientQueueSelection}".trim() === "true" && patientQueueListElement.status!=="COMPLETED") {
                    action += "<i  style=\"font-size: 25px;\" class=\"icon-edit edit-action\" title=\"Capture Vitals\" data-toggle=\"modal\" data-target=\"#pick_patient_queue_dialog\" data-id=\"\" data-patientqueueid='" + element.patientQueueId + "' data-url='" + vitalsPageLocation + "'></i>";
                } else {
                    action += "<i style=\"font-size: 25px;\" class=\"icon-edit edit-action\" title=\"Capture Vitals\" onclick=\" location.href = '" + vitalsPageLocation + "'\"></i>";
                }


                var waitingTime = getWaitingTime(patientQueueListElement.dateCreated, patientQueueListElement.dateChanged);
                dataRowTable += "<tr>";
                dataRowTable += "<td>" + patientQueueListElement.visitNumber.substring(15) + "</td>";
                dataRowTable += "<td>" + patientQueueListElement.patientNames + "</td>";
                dataRowTable += "<td>" + patientQueueListElement.gender + "</td>";
                dataRowTable += "<td>" + patientQueueListElement.age + "</td>";
                if (element.status !== "COMPLETED") {

                    if (patientQueueListElement.priorityComment != null) {
                        dataRowTable += "<td>" + patientQueueListElement.priorityComment + "</td>";
                    } else {
                        dataRowTable += "<td></td>";
                    }
                }
                dataRowTable += "<td>" + patientQueueListElement.locationFrom.substring(0, 3) + "</td>";
                dataRowTable += "<td>" + waitingTime + "</td>";
                dataRowTable += "<td>" + action + "</td>";
                dataRowTable += "</tr>";
                if (element.status === "PENDING") {
                    stillInQueue += 1;
                    stillInQueueDataRows += dataRowTable;

                } else if (element.status === "COMPLETED") {
                    completedQueue += 1;
                    completedDataRows += dataRowTable;
                }
            }
        );

        if (stillInQueueDataRows !== "") {
            jq("#triage-queue-list-table").html("");
            jq("#triage-queue-list-table").append(headerPending + stillInQueueDataRows + footer);

        }
        if (completedDataRows !== "") {
            jq("#triage-completed-list-table").html("");
            jq("#triage-completed-list-table").append(headerCompleted + completedDataRows + footer);

        }
        jq("#triage-pending-number").html("");
        jq("#triage-pending-number").append(stillInQueue);
        jq("#triage-completed-number").html("");
        jq("#triage-completed-number").append(completedQueue);
    }

    //SUPPORTIVE FUNCTIONS//
    //Get Waiting Time For Patient In Queue

</script>
<br/>


<div class="card">
    <div class="card-header">
        <div class="">
            <div class="row">
                <div class="col-3">
                    <div>
                        <h1 style="color: maroon" class="">${ui.message("Triage Queue")}</i></h1>
                    </div>

                    <div>
                        <h2>${currentProvider?.person?.personName?.fullName}</h2>
                    </div>

                    <div class="vertical"></div>
                </div>

                <div class="col-8">
                    <form method="get" id="patient-triage-search-form" onsubmit="return false">
                        <input id="patient-triage-search" name="patient-triage-search"
                               placeholder="${ui.message("coreapps.findPatient.search.placeholder")}"
                               autocomplete="off" class="provider-dashboard-patient-search"/>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <div class="card-body">
        <ul class="nav nav-tabs nav-fill" id="myTab" role="tablist">
            <li class="nav-item">
                <a class="nav-item nav-link active" id="home-tab" data-toggle="tab" href="#queue-triage" role="tab"
                   aria-controls="queue-triage-tab" aria-selected="true">Pending Patients <span style="color:red"
                                                                                                id="triage-pending-number">0</span>
                </a>
            </li>
            <li class="nav-item">
                <a class="nav-link" id="profile-tab" data-toggle="tab" href="#triage-completed-list" role="tab"
                   aria-controls="triage-completed-list-tab" aria-selected="false">Completed Patients <span
                        style="color:red" id="triage-completed-number">0</span>
                </a>
            </li>
        </ul>

        <div class="tab-content" id="myTabContent">
            <div class="tab-pane fade show active" id="queue-triage" role="tabpanel"
                 aria-labelledby="queue-triage-tab">
                <div class="info-body">
                    <div id="triage-queue-list-table">
                    </div>
                </div>
            </div>

            <div class="tab-pane fade" id="triage-completed-list" role="tabpanel"
                 aria-labelledby="triage-completed-list-tab">
                <div class="info-body">
                    <div id="triage-completed-list-table">
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

${ui.includeFragment("ugandaemrpoc", "pickPatientFromQueue", [provider: currentProvider, currentLocation: currentLocation])}

<% } %>







