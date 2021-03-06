<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<html>
<head>
<title>OSM Watch</title>

<link rel="stylesheet" href="resources/style.css" />

<link rel="stylesheet"
	href="http://ia601209.us.archive.org/23/items/LeafletCDN/dist/leaflet.css" />
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.1/jquery.min.js"></script>
<script
	src="//ajax.googleapis.com/ajax/libs/jqueryui/1.8.23/jquery-ui.min.js"></script>

<script src="resources/jquery.lightbox_me.js"></script>
<script src="resources/jquery.dataTables.min.js"></script>
<link rel="stylesheet" href="resources/jquery.dataTables.css" />

<link rel="stylesheet"
	href="http://cdn.leafletjs.com/leaflet-0.4/leaflet.css" />
<script src="http://cdn.leafletjs.com/leaflet-0.4/leaflet.js"></script>

<script src="resources/lfdraw/leaflet.draw.js"></script>
<link rel="stylesheet" href="resources/lfdraw/leaflet.draw.css" />

<link rel="stylesheet" href="resources/jqui/jquery-ui-1.9.0.custom.css" />


<script src="resources/jquery.dateFormat.js"></script>

<script src="resources/watch.js"></script>



<script type="text/javascript">
/*
jQuery(document).ready(function() {
  var hints = {
    "admin_name_input": "Enter an admin relation",
  };
  
  var hideHint = function(field, text){
    if (jQuery(field).val() === text) {
      jQuery(field).val("");
      jQuery(field).removeClass('hint');
    }
  };
  
  var showHint = function(field, text){
    if (jQuery(field).val() === "") {
      jQuery(field).val(text);
      jQuery(field).addClass('hint');
    }
  };

  var text;
  
  for (fieldName in hints) {
    text = hints[fieldName];
    jQuery("#"+fieldName).val(text).focus((function(text) {
      return function() {hideHint(this, text);};
    })(text)).blur((function(text) {
      return function() {showHint(this, text);};
    })(text)).addClass('hint');
  }
  
 
  });
});
*/
</script>

</head>

<body>
	<div id="titlebar">
		<div class="title">OSM Watch</div>
	</div>


	<div class="content">
		<c:if test="${empty ud}">
			<div id="logged_in">
				<a href="authenticate">Login with your OpenStreetMap account</a> to
				manage your alerts.
			</div>
		</c:if>
		<c:if test="${not empty ud}">
			<div id="logged_in">
				Logged in as
				<c:out value="${ud.screenName}" />
				<br />
				E-mail address: <input type="text" id="email_input" value="${ud.emailAddress}" />
				<input type="submit" id="email_submit" value="Update" style="font-size:1Em"/><br />
				(required for email notifications)  
			</div>

			<h2>Your alerts</h2>
			<p>
				<a href="#" id="new_alert_button">Create a new alert</a>
			</p>

			<div id="alerts_list"></div>


			<div id="add_alert_box">
				<a id="close_x" class="close sprited" href="#">close</a>
				<form style="margin-top: 10px">
					<fieldset>
						<legend>Name</legend>
						Name of the alert: <input name="name" id="name_input" />
					</fieldset>

					<fieldset>
						<legend>Filter</legend>
						<select id="filter_type">
							<option value="josm" selected="selected">JOSM</option>
							<option value="first_time">New contributor</option>
							<option value="cadastre">French Cadastre import</option>
							<option value="custom">Custom</option>
						</select>
						<div class="syntax_help" id="josm_syntax_help">
							Syntax examples (JOSM compatible):
							<table>
								<tr>
									<td>
										<ul>
											<li>Match in any tag key or value: "highway", "Baker
												Street"</li>
											<li>Tag key match: "highway=*"</li>
											<li>Tag value match: "*=value"</li>
											<li>Exact tag match: "highway=primary"</li>

										</ul>
									</td>
									<td>
										<ul>
											<li>Regexp search: "source=.*oogle.*"</li>
											<li>Boolean search: "expr | expr", "expr OR expr", "expr
												&& expr", "-expr"</li>
											<li>Meta match: "version:17", "tags:1-3", "type:way"</li>
											<li>(ways only) nb nodes: "nodes:10-15"</li>
										</ul>
									</td>
								</tr>
							</table>
						</div>
						<div id="josm_fields">
							<input style="width: 100%;" name="filter_params"
								id="josm_params_input" />
						</div>
						<div id="custom_fields" style="display: none">
							Class: <input style="width: 80%;" name="filter_class"
								id="filter_class_input" style="display:none" /> <br /> Params:
							<input style="width: 80%;" name="filter_params"
								id="filter_params_input" />
						</div>
					</fieldset>

					<input type="hidden" name="existing_id" id="existing_id_input" />

					<fieldset>
						<legend>Geo restriction</legend>
						<div class="syntax_help">Draw a polygon on the map, or enter
							an administrative boundary</div>
						<input style="width: 100%;" name="xx" id="admin_name_input" />
						<div id="results"></div>
						<div id="map"></div>
						<input style="width: 100%;" name="polygon" id="polygon_input" />
					</fieldset>
					<input type="submit" value="Add" id="add_alert_button" />
					<!--  
          
            <div id="map"></div>
           
                <table>
                   <tr>
                        <td>Name of the alert</td>
                        <td><input name="name" id="name_input"/></td>
                    </tr>
                    <tr>
                        <td>Watched tags (comma-separated, empty for all tags)</td>
                        <td><input name="tags" id="tags_input" /></td>
                    </tr>
                    <tr>
                        <td>Watched polygon (empty for everywhere)</td>
                        <td><input name="polygon" id="polygon_input"/></td>
                    </tr>
                      <tr>
                        <td><input type="submit" value="Add" id="add_alert_button" /></td>
                    </tr>
                </table>

            </form>
            -->
			</div>
		</c:if>
		<h2>Public alerts</h2>
		<div id="public_alerts_list"></div>

	</div>



	<div id="footer">
		<div id="footer_content">
			<p>OSM-Watch tracks what happens on OpenStreetMap in real-time,
				and notifies you when changes match some criteria.</p>

			<p>
				Code on <a href="https://github.com/cstenac/osm-watch">Github</a>
			</p>
		</div>
	</div>





</body>
</html>