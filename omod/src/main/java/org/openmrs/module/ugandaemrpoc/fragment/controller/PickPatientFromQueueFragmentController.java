package org.openmrs.module.ugandaemrpoc.fragment.controller;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.codehaus.jackson.map.ObjectMapper;
import org.openmrs.*;
import org.openmrs.api.LocationService;
import org.openmrs.api.PatientService;
import org.openmrs.api.context.Context;
import org.openmrs.module.aijar.AijarConstants;
import org.openmrs.module.appui.UiSessionContext;
import org.openmrs.module.coreapps.fragment.controller.visit.QuickVisitFragmentController;
import org.openmrs.module.emrapi.adt.AdtService;
import org.openmrs.module.patientqueueing.api.PatientQueueingService;
import org.openmrs.module.patientqueueing.model.PatientQueue;
import org.openmrs.module.ugandaemrpoc.api.UgandaEMRPOCService;
import org.openmrs.ui.framework.SimpleObject;
import org.openmrs.ui.framework.UiUtils;
import org.openmrs.ui.framework.annotation.SpringBean;
import org.openmrs.ui.framework.fragment.FragmentModel;
import org.openmrs.util.OpenmrsUtil;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpServletRequest;
import java.io.IOException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import static org.openmrs.module.ugandaemrpoc.UgandaEMRPOCConfig.PHARMACY_LOCATION_UUID;

public class PickPatientFromQueueFragmentController {

    protected final Log log = LogFactory.getLog(getClass());

    public PickPatientFromQueueFragmentController() {
    }

    public void controller() {

    }


    public SimpleObject getCurrentDateTime() {
        SimpleObject simpleObject = new SimpleObject();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ");
        String dateStr = sdf.format(new Date());
        ObjectMapper objectMapper = new ObjectMapper();

        try {
            simpleObject.put("currentDateTime", objectMapper.writeValueAsString(dateStr));
        } catch (IOException e) {
           log.error(e);
        }
        return simpleObject;
    }
}
