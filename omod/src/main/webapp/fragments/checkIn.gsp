<%
    ui.includeJavascript("patientqueueing", "patientqueue.js")
%>

<script>
    jq(document).ready(function () {
        jq("#patient_status_container").hide();
        jq("#visit_comment_container").hide();
        jq("#location_id").change(function () {
            if (jq("#location_id").val() !== "ff01eaab-561e-40c6-bf24-539206b521ce") {
                jq("#patient_status_container").show();
                jq("#visit_comment_container").show();
            } else {
                jq("#patient_status_container").hide();
                jq("#visit_comment_container").hide();
            }
        });
    });

    function printTriageRecord(divIdToPrint, dataToPrint) {
        var divToPrint = document.getElementById(divIdToPrint);
        var newWin = window.open('', 'Print-Window');
        var checkInData = "";
        jq("#check_in_receipt").html("");
        if (dataToPrint.patientTriageQueue !== "") {
            checkInData += "<table>";
            checkInData += "<tr><th width=\"50%\" style=\"text-align: left\">Check In Date:</th><td>%s</td></tr>".replace("%s", dataToPrint.patientTriageQueue.dateCreated);
            checkInData += "<tr><th width=\"50%\" style=\"text-align: left\">Patient Names:</th><td>%s</td></tr>".replace("%s", dataToPrint.patientTriageQueue.patientNames);
            checkInData += "<tr><th width=\"50%\" style=\"text-align: left\">Visit No.:</th><td>%s</td></tr>".replace("%s", dataToPrint.patientTriageQueue.visitNumber.substring(15));
            checkInData += "<tr><th width=\"50%\" style=\"text-align: left\">Gender:</th><td>%s</td></tr>".replace("%s", dataToPrint.patientTriageQueue.gender);
            checkInData += "<tr><th width=\"50%\" style=\"text-align: left\">Entry Point:</th><td>%s</td></tr>".replace("%s", dataToPrint.patientTriageQueue.locationFrom.substring(0, 3));
            checkInData += "<tr><th width=\"50%\" style=\"text-align: left\">Registration Attendant:</th><td>%s</td></tr>".replace("%s", dataToPrint.patientTriageQueue.creatorNames);
            checkInData += "</table>";
        }
        jq("#check_in_receipt").append(checkInData);
        newWin.document.open();
        newWin.document.write('<html><body onload="window.print()">' + divToPrint.innerHTML + '</body></html>');
        newWin.document.close();
        setTimeout(function () {
            newWin.close();
        }, 10);
    }
</script>
<style>
.modal-header {
    background: #000;
    color: #ffffff;
}

.print-only {
    display: none;
}

hr.printhr {
    border: 1px solid red;
}
</style>

<script>
    if (jQuery) {
    }
</script>

<div class="modal fade" id="add_patient_to_queue_dialog" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel"
     aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                Check in <span id="checkin_patient_names"></span><i class="icon-check medium"></i>
            </div>

            <div class="modal-body">
                <div class="container">
                    <input type="hidden" id="patient_id" name="patient_id" value="">
                    <input type="hidden" id="location_from_id" name="location_from_id" value="4501e132-07a2-4201-9dc8-2f6769b6d412">
                    <div class="row">
                        <div class="col-5">Next Service Point:</div>
                        <div class="col-7">
                            <div class="form-group">
                                <select class="form-control" id="location_id" name="location_id">
                                    <option value="">Select Next Service Point</option>
                                    <% if (locationList != null) {
                                        locationList.each { %>
                                    <option value="${it.uuid}">${it.name}</option>
                                    <%
                                            }
                                        }
                                    %>
                                </select>
                                <span class="field-error" style="display: none;"></span>
                                <% if (locationList == null) { %>
                                <div><${ui.message("patientqueueing.select.error")}</div>
                                <% } %>
                            </div>
                        </div>
                    </div>

                    <div class="row" id="patient_status_container">
                        <div class="col-4">Urgency of Care:</div>

                        <div class="col-8">
                            <div class="form-group">
                                <select class="form-control" id="patient_status" name="patient_status">
                                    <option value="">Select Urgency of Care</option>
                                    <option value="normal">Normal</option>
                                    <option value="emergency">Emergency</option>
                                </select>
                                <span class="field-error" style="display: none;"></span>
                            </div>
                        </div>
                    </div>

                    <div class="row" id="visit_comment_container">
                        <div class="col-4">Visit Type:</div>

                        <div class="col-8">
                            <div class="form-group">
                                <select class="form-control" id="visit_comment" name="visit_comment">
                                    <option value="">Select Visit Type</option>
                                    <option value="new visit">New Visit</option>
                                    <option value="revisit">Revisit</option>
                                </select>
                                <span class="field-error" style="display: none;"></span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>


            <div class="modal-footer form">
                <button type="button" class="btn btn-danger" data-dismiss="modal">Cancel</button>
                <input type="submit" class="confirm" id="checkin" value="Check In">
            </div>
        </div>
    </div>
</div>

<div id="printSection" class="print-only">
    <center>
        <div style="width: 30%">
            <div><img width="100px" src="${ui.resourceLink("aijar", "images/moh_logo_large.png")}"/></div>

            <div><h2>${healthCenterName}</h2></div>
            <hr style="border: 1px solid red;"/>

            <div><h3>Visit Registration Receipt</h3></div>

            <div id="check_in_receipt" align="left" style="font-size: 10px">
            </div>
        </div>
    </center>
</div>


