// sensing agent


/* Initial beliefs and rules */

role_goal(R, G) :- role_mission(R, _, M) & mission_goal(M, G).
can_achieve(G) :- .relevant_plans({+!G[scheme(_)]}, LP) & LP \== [].
i_have_plans_for(R) :- not (role_goal(R, G) & not can_achieve(G)).

/* Initial goals */
!start. // the agent has the goal to start

/* 
 * Plan for reacting to the addition of the goal !start
 * Triggering event: addition of goal !start
 * Context: the agent believes that it can manage a group and a scheme in an organization
 * Body: greets the user
*/
@start_plan
+!start : true <-
	.print("Hello world").

@react_plan
+react(OrgName) : true <-
	joinWorkspace(OrgName);
	.print("Sensing agent has joined: ", OrgName);
	lookupArtifact(OrgName, Id);
	focus(Id).
+group(GroupId, GroupType, ArtId) : true <-
	lookupArtifact(GroupType, Id);
	focus(Id).
+scheme(SchemeId, SchemeType, ArtId) : true <-
	lookupArtifact(SchemeType, Id);
	focus(Id);
	.print("Sensing Agent focusing on scheme");
	!reasonRole.

@reason_role_plan
+!reasonRole : role_goal(R, G) & i_have_plans_for(R) <-
	adoptRole(R).

/* 
 * Plan for reacting to the addition of the goal !read_temperature
 * Triggering event: addition of goal !read_temperature
 * Context: true (the plan is always applicable)
 * Body: reads the temperature using a weather station artifact and broadcasts the reading
*/
@read_temperature_plan
+!read_temperature : true <-
	.print("I will read the temperature");
	makeArtifact("weatherStation", "tools.WeatherStation", [], WeatherStationId); // creates a weather station artifact
	focus(WeatherStationId); // focuses on the weather station artifact
	readCurrentTemperature(47.42, 9.37, Celcius); // reads the current temperature using the artifact
	.print("Temperature Reading (Celcius): ", Celcius);
	.broadcast(tell, temperature(Celcius)). // broadcasts the temperature reading

/* Import behavior of agents that work in CArtAgO environments */
{ include("$jacamoJar/templates/common-cartago.asl") }

/* Import behavior of agents that work in MOISE organizations */
{ include("$jacamoJar/templates/common-moise.asl") }

/* Import behavior of agents that reason on MOISE organizations */
{ include("$moiseJar/asl/org-rules.asl") }

/* Import behavior of agents that react to organizational events
(if observing, i.e. being focused on the appropriate organization artifacts) */
{ include("inc/skills.asl") }