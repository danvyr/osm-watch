package fr.openstreetmap.watch.controllers;

import java.io.IOException;
import java.util.Date;
import java.util.List;

import javax.management.Query;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import fr.openstreetmap.watch.DatabaseManager;
import fr.openstreetmap.watch.model.db.Alert;
import fr.openstreetmap.watch.model.db.AlertMatch;
import fr.openstreetmap.watch.model.db.User;
import fr.openstreetmap.watch.util.SimpleXMLWriter;

@Controller
public class RSSFeedController {
	private DatabaseManager dbManager;
	@Autowired
	public void setDatabaseManager(DatabaseManager dbManager) {
		this.dbManager = dbManager;
	}

	/*
	 * <?xml version="1.0" encoding="iso-8859-1"?>
<rss version="2.0">
    <channel>
        <title>Mon site</title>
        <description>Ceci est un exemple de flux RSS 2.0</description>
        <lastBuildDate>Sat, 07 Sep 2002 00:00:01 GMT</lastBuildDate>
        <link>http://www.example.org</link>
        <item>
            <title>Actualité N°1</title>
            <description>Ceci est ma première actualité</description>
            <pubDate>Sat, 07 Sep 2002 00:00:01 GMT</pubDate>
            <link>http://www.example.org/actu1</link>
        </item>
    </channel>
</rss>
	 */

	@RequestMapping(value="/api/rss_feed")
	public void newAlert(@RequestParam("key") String key, 
			HttpServletRequest req, HttpServletResponse resp) throws IOException {
		User ud = AuthenticationHandler.verityAuth(req, dbManager);
		if (ud == null) {
			resp.sendError(403, "Not authenticated");
			return;
		}
		dbManager.begin();
		try {
			javax.persistence.Query q = dbManager.getEM().createQuery("SELECT x FROM Alert x where uniqueKey = ?1");
			q.setParameter(1, key);
			List<Alert> aa = q.getResultList();
			if (aa.size() == 0) {
				resp.sendError(500, "Alert does not exist");
				return;
			}
			Alert a = aa.get(0);


			resp.setContentType("text/xml");
			SimpleXMLWriter sxw = new SimpleXMLWriter(resp.getWriter());

			sxw.entity("rss")
			.attr("version", "2.0")
			.entity("channel");

			sxw.entity("title").text("OSM Watch alert: " + a.getName()).endEntity();
			
			for (AlertMatch am : a.getAlertMatches()) {
				sxw.entity("item");
				sxw.entity("title").text("Changeset " + am.getChangesetId()).endEntity();
				sxw.entity("link").text("http://www.openstreetmap.org/browse/changeset/" + am.getChangesetId()).endEntity();
				sxw.entity("description").text("Matched on " + new Date(am.getMatchTimestamp()) + am.getReason()).endEntity();
				sxw.endEntity();
				/*            	 <item>
                 <title>Actualité N°1</title>
                 <description>Ceci est ma première actualité</description>
                 <pubDate>Sat, 07 Sep 2002 00:00:01 GMT</pubDate>
                 <link>http://www.example.org/actu1</link>
             </item>*/
			}

			sxw.endEntity().endEntity().close();

		} catch (Exception e) {
			logger.error("Failed to get RSS", e);
			resp.setStatus(500);
			resp.setContentType("application/json");
			resp.getWriter().write("{\"ok\": \"0\"}");
		} finally {
			dbManager.rollback();
		}
	}

	private static Logger logger = Logger.getLogger("osm.watch.controller");
}