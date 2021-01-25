package org.openmrs.module.ugandaemrpoc.api;

import org.openmrs.module.patientqueueing.mapper.PatientQueueMapper;

import java.io.Serializable;

public class PatientQueueVisitMapper extends PatientQueueMapper  implements Serializable {
    Integer visitId;
    String uuid;

    public String getUuid() {
        return uuid;
    }

    public void setUuid(String uuid) {
        this.uuid = uuid;
    }

    public Integer getVisitId() {
        return visitId;
    }

    public void setVisitId(Integer visitId) {
        this.visitId = visitId;
    }
}
