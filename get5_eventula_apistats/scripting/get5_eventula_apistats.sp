/**
 * =============================================================================
 * Get5 web API integration
 * Copyright (C) 2016. Sean Lewis.  All rights reserved.
 * =============================================================================
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "include/get5.inc"
#include "include/logdebug.inc"
#include <cstrike>
#include <sourcemod>

#include "get5/util.sp"
#include "get5/version.sp"

#include <SteamWorks>
#include <json>  // github.com/clugg/sm-json

#include "get5/jsonhelpers.sp"

#pragma semicolon 1
#pragma newdecls required

ConVar g_APIKeyCvar;
char g_APIKey[128];
char g_APIKeyOld[128];

ConVar g_APIURLCvar;
char g_APIURL[128];
char g_APIURLOld[128];


// clang-format off
public Plugin myinfo = {
  name = "Get5 eventula Web API Integration",
  author = "Lan2Play Team & splewis",
  description = "Records match stats to a eventula-get5-web api",
  version = PLUGIN_VERSION,
  url = "https://github.com/Lan2Play/get5_eventula_apistats"
};
// clang-format on

public void OnPluginStart() {
  InitDebugLog("get5_debug", "get5_api");
  LogDebug("OnPluginStart version=%s", PLUGIN_VERSION);
  g_APIKeyCvar = CreateConVar("get5_eventula_apistats_key", "", "Match API key, this is automatically set through rcon");
  HookConVarChange(g_APIKeyCvar, ApiInfoChanged);

  g_APIURLCvar = CreateConVar("get5_eventula_apistats_url", "", "URL the get5 api is hosted at");

  HookConVarChange(g_APIURLCvar, ApiInfoChanged);

  RegConsoleCmd("get5_eventula_apistats_available",
                Command_Available); 
}

static Action Command_Available(int client, int args) {
  char versionString[64] = "unknown";
  ConVar versionCvar = FindConVar("get5_version");
  if (versionCvar != null) {
    versionCvar.GetString(versionString, sizeof(versionString));
  }

  JSON_Object json = new JSON_Object();

  json.SetInt("gamestate", view_as<int>(Get5_GetGameState()));
  json.SetInt("available", 1);
  json.SetString("plugin_version", versionString);

  char buffer[256];
  json.Encode(buffer, sizeof(buffer), true);
  ReplyToCommand(client, buffer);

  json_cleanup_and_delete(json);

  return Plugin_Handled;
}



void ApiInfoChanged(ConVar convar, const char[] oldValue, const char[] newValue) {
  LogDebug("ApiInfoChanged called");
  LogDebug("ApiInfoChanged before setting g_APIKey %s", g_APIKey);
  LogDebug("ApiInfoChanged before setting g_APIKeyOld %s", g_APIKeyOld);
  LogDebug("ApiInfoChanged before setting g_APIURL %s", g_APIURL);
  LogDebug("ApiInfoChanged before setting g_APIURLOld %s", g_APIURLOld);

  strcopy(g_APIKeyOld, sizeof(g_APIKeyOld), g_APIKey);
  strcopy(g_APIURLOld, sizeof(g_APIURLOld), g_APIURL);

  LogDebug("ApiInfoChanged after copy g_APIKey %s", g_APIKey);
  LogDebug("ApiInfoChanged after copy g_APIKeyOld %s", g_APIKeyOld);
  LogDebug("ApiInfoChanged after copy g_APIURL %s", g_APIURL);
  LogDebug("ApiInfoChanged after copy g_APIURLOld %s", g_APIURLOld);

  g_APIKeyCvar.GetString(g_APIKey, sizeof(g_APIKey));
  g_APIURLCvar.GetString(g_APIURL, sizeof(g_APIURL));

  // Add a trailing backslash to the api url if one is missing.
  int len = strlen(g_APIURL);
  if (len > 0 && g_APIURL[len - 1] != '/') {
    StrCat(g_APIURL, sizeof(g_APIURL), "/");
  }

  LogDebug("ApiInfoChanged after setting g_APIKey %s", g_APIKey);
  LogDebug("ApiInfoChanged after setting g_APIKeyOld %s", g_APIKeyOld);
  LogDebug("ApiInfoChanged after setting g_APIURL %s", g_APIURL);
  LogDebug("ApiInfoChanged after setting g_APIURLOld %s", g_APIURLOld);
  
  LogDebug("get5_eventula_apistats_url now set to %s", g_APIURL);
}

static Handle CreateRequest(EHTTPMethod httpMethod, const char[] apiMethod, any:...) {

  char APIKey[128];
  char APIURL[128];
  LogDebug("createrequest called");
  LogDebug("createrequest g_APIKey %s", g_APIKey);
  LogDebug("createrequest g_APIKeyOld %s", g_APIKeyOld);
  LogDebug("createrequest g_APIURL %s", g_APIURL);
  LogDebug("createrequest g_APIURLOld %s", g_APIURLOld);

  if (StrEqual(g_APIKey, ""))
  {
    LogDebug("g_APIKey detected empty, befor strcopy");
    LogDebug("createrequest g_APIKey %s", g_APIKey);
    LogDebug("createrequest g_APIKeyOld %s", g_APIKeyOld);
    strcopy(APIKey, sizeof(APIKey), g_APIKeyOld);
    LogDebug("g_APIKey detected empty, after strcopy");
    LogDebug("createrequest g_APIKey %s", g_APIKey);
    LogDebug("createrequest g_APIKeyOld %s", g_APIKeyOld);
    g_APIKeyOld[0] = '\0';

    LogDebug("g_APIKey detected empty, after emptying");
    LogDebug("createrequest g_APIKey %s", g_APIKey);
    LogDebug("createrequest g_APIKeyOld %s", g_APIKeyOld);
    LogDebug("createrequest APIKey %s", APIKey);
  }
  else
  {
    LogDebug("g_APIKey detected not empty, befor strcopy");
    LogDebug("createrequest g_APIKey %s", g_APIKey);
    LogDebug("createrequest g_APIKeyOld %s", g_APIKeyOld);
    strcopy(APIKey, sizeof(APIKey), g_APIKey);
    LogDebug("g_APIKey detected not empty, after strcopy");
    LogDebug("createrequest g_APIKey %s", g_APIKey);
    LogDebug("createrequest g_APIKeyOld %s", g_APIKeyOld);
    LogDebug("createrequest APIKey %s", APIKey);
  }
  if (StrEqual(g_APIURL, ""))
  {
    LogDebug("g_APIURL detected empty, befor strcopy");
    LogDebug("createrequest g_APIURL %s", g_APIURL);
    LogDebug("createrequest g_APIURLOld %s", g_APIURLOld);
    strcopy(APIURL, sizeof(APIURL), g_APIURLOld);
    LogDebug("g_APIURL detected empty, after strcopy");
    LogDebug("createrequest g_APIURL %s", g_APIURL);
    LogDebug("createrequest g_APIURLOld %s", g_APIURLOld);
    g_APIURLOld[0] = '\0';
    LogDebug("g_APIURL detected empty, after emptying");
    LogDebug("createrequest g_APIURL %s", g_APIURL);
    LogDebug("createrequest g_APIURLOld %s", g_APIURLOld);
    LogDebug("createrequest APIURL %s", APIURL);
  }
  else
  {
    LogDebug("g_APIURL detected not empty, befor strcopy");
    LogDebug("createrequest g_APIURL %s", g_APIURL);
    LogDebug("createrequest g_APIURLOld %s", g_APIURLOld);
    strcopy(APIURL, sizeof(APIURL), g_APIURL);
    LogDebug("g_APIURL detected not empty, after strcopy");
    LogDebug("createrequest g_APIURL %s", g_APIURL);
    LogDebug("createrequest g_APIURLOld %s", g_APIURLOld);
    LogDebug("createrequest APIURL %s", APIURL);
  }

  char url[1024];
  FormatEx(url, sizeof(url), "%s%s", APIURL, apiMethod);
  char formattedUrl[1024];
  char authKey[1024];
  VFormat(formattedUrl, sizeof(formattedUrl), url, 3);

  LogDebug("Trying to create request to url %s", formattedUrl);

  Handle req = SteamWorks_CreateHTTPRequest(httpMethod, formattedUrl);
  if (StrEqual(APIKey, "")) {
    LogError("get5_eventula_apistats_key is empty, abort request", formattedUrl);
    return INVALID_HANDLE;

  } else if (req == INVALID_HANDLE) {
    LogError("Failed to create request to %s", formattedUrl);
    return INVALID_HANDLE;

  } else {
    SteamWorks_SetHTTPCallbacks(req, RequestCallback);
    FormatEx(authKey, sizeof(authKey), "Bearer %s", APIKey);
    SteamWorks_SetHTTPRequestHeaderValue(req, "Authorization", authKey);
    return req;
  }
}

int RequestCallback(Handle request, bool failure, bool requestSuccessful,
                    EHTTPStatusCode statusCode) {
  if (failure || !requestSuccessful) {
    LogError("API request failed, HTTP status code = %d", statusCode);
    char response[1024];
    SteamWorks_GetHTTPResponseBodyData(request, response, sizeof(response));
    LogError(response);
    return;
  }
}

public void Get5_OnSeriesInit() {

}

public void Get5_OnGoingLive(const Get5GoingLiveEvent event) {
  char mapName[64];
  GetCurrentMap(mapName, sizeof(mapName));
  Handle req = CreateRequest(k_EHTTPMethodPOST, "golive/%d", event.MapNumber);

  if (req != INVALID_HANDLE) {
    AddStringParam(req, "mapname", mapName);
    SteamWorks_SendHTTPRequest(req);
  }
  delete req;

  Get5_AddLiveCvar("get5_eventula_apistats_key", g_APIKey);
  Get5_AddLiveCvar("get5_eventula_apistats_url", g_APIURL);
}

static void UpdateRoundStats(const int mapNumber) {
  int t1score = CS_GetTeamScore(Get5_Get5TeamToCSTeam(Get5Team_1));
  int t2score = CS_GetTeamScore(Get5_Get5TeamToCSTeam(Get5Team_2));

  Handle req = CreateRequest(k_EHTTPMethodPOST, "updateround/%d", mapNumber);
  if (req != INVALID_HANDLE) {
    AddIntParam(req, "team1score", t1score);
    AddIntParam(req, "team2score", t2score);
    SteamWorks_SendHTTPRequest(req);
  }
  delete req;

  KeyValues kv = new KeyValues("Stats");
  Get5_GetMatchStats(kv);
  char mapKey[32];
  FormatEx(mapKey, sizeof(mapKey), "map%d", mapNumber);
  if (kv.JumpToKey(mapKey)) {
    if (kv.JumpToKey("team1")) {
      UpdatePlayerStats(mapNumber, kv, Get5Team_1);
      kv.GoBack();
    }
    if (kv.JumpToKey("team2")) {
      UpdatePlayerStats(mapNumber, kv, Get5Team_2);
      kv.GoBack();
    }
    kv.GoBack();
  }
  delete kv;
}

public void Get5_OnMapResult(const Get5MapResultEvent event) {

  char winnerString[64];
  GetTeamString(event.Winner.Team, winnerString, sizeof(winnerString));

  Handle req = CreateRequest(k_EHTTPMethodPOST, "finalize/%d", event.MapNumber);
  if (req != INVALID_HANDLE) {
    AddIntParam(req, "team1score", event.Team1Score);
    AddIntParam(req, "team2score", event.Team2Score);
    AddStringParam(req, "winner", winnerString);
    SteamWorks_SendHTTPRequest(req);
  }
  delete req;
}

static void AddIntStat(Handle req, KeyValues kv, const char[] field) {
  AddIntParam(req, field, kv.GetNum(field));
}

static void UpdatePlayerStats(const int mapNumber, const KeyValues kv, const Get5Team team) {
  char name[MAX_NAME_LENGTH];
  char auth[AUTH_LENGTH];

  if (kv.GotoFirstSubKey()) {
    do {
      kv.GetSectionName(auth, sizeof(auth));
      kv.GetString("name", name, sizeof(name));
      char teamString[16];
      GetTeamString(team, teamString, sizeof(teamString));

      Handle req = CreateRequest(k_EHTTPMethodPOST, "updateplayer/%d/%s", mapNumber, auth);
      if (req != INVALID_HANDLE) {
        AddStringParam(req, "team", teamString);
        AddStringParam(req, STAT_NAME, name);
        AddIntStat(req, kv, STAT_KILLS);
        AddIntStat(req, kv, STAT_DEATHS);
        AddIntStat(req, kv, STAT_ASSISTS);
        AddIntStat(req, kv, STAT_FLASHBANG_ASSISTS);
        AddIntStat(req, kv, STAT_TEAMKILLS);
        AddIntStat(req, kv, STAT_SUICIDES);
        AddIntStat(req, kv, STAT_DAMAGE);
        AddIntStat(req, kv, STAT_UTILITY_DAMAGE);
        AddIntStat(req, kv, STAT_ENEMIES_FLASHED);
        AddIntStat(req, kv, STAT_FRIENDLIES_FLASHED);
        AddIntStat(req, kv, STAT_KNIFE_KILLS);
        AddIntStat(req, kv, STAT_HEADSHOT_KILLS);
        AddIntStat(req, kv, STAT_ROUNDSPLAYED);
        AddIntStat(req, kv, STAT_BOMBPLANTS);
        AddIntStat(req, kv, STAT_BOMBDEFUSES);
        AddIntStat(req, kv, STAT_1K);
        AddIntStat(req, kv, STAT_2K);
        AddIntStat(req, kv, STAT_3K);
        AddIntStat(req, kv, STAT_4K);
        AddIntStat(req, kv, STAT_5K);
        AddIntStat(req, kv, STAT_V1);
        AddIntStat(req, kv, STAT_V2);
        AddIntStat(req, kv, STAT_V3);
        AddIntStat(req, kv, STAT_V4);
        AddIntStat(req, kv, STAT_V5);
        AddIntStat(req, kv, STAT_FIRSTKILL_T);
        AddIntStat(req, kv, STAT_FIRSTKILL_CT);
        AddIntStat(req, kv, STAT_FIRSTDEATH_T);
        AddIntStat(req, kv, STAT_FIRSTDEATH_CT);
        AddIntStat(req, kv, STAT_TRADEKILL);
        AddIntStat(req, kv, STAT_KAST);
        AddIntStat(req, kv, STAT_CONTRIBUTION_SCORE);
        AddIntStat(req, kv, STAT_MVP);
        SteamWorks_SendHTTPRequest(req);
      }
      delete req;

    } while (kv.GotoNextKey());
    kv.GoBack();
  }
}

static void AddStringParam(Handle request, const char[] key, const char[] value) {
  if (!SteamWorks_SetHTTPRequestGetOrPostParameter(request, key, value)) {
    LogError("Failed to add http param %s=%s", key, value);
  } else {
    LogDebug("Added param %s=%s to request", key, value);
  }
}

static void AddIntParam(Handle request, const char[] key, int value) {
  char buffer[32];
  IntToString(value, buffer, sizeof(buffer));
  AddStringParam(request, key, buffer);
}

public void Get5_OnSeriesResult(const Get5SeriesResultEvent event) {
  char winnerString[64];
  GetTeamString(event.Winner.Team, winnerString, sizeof(winnerString));

  KeyValues kv = new KeyValues("Stats");
  Get5_GetMatchStats(kv);
  bool forfeit = kv.GetNum(STAT_SERIES_FORFEIT, 0) != 0;
  delete kv;

  Handle req = CreateRequest(k_EHTTPMethodPOST, "finalize");
  if (req != INVALID_HANDLE) {
    AddStringParam(req, "winner", winnerString);
    AddIntParam(req, "forfeit", forfeit);
    SteamWorks_SendHTTPRequest(req);
  }
  delete req;

  CreateTimer(GetCurrentMatchRestartDelay() + 10.0, FreeServer);

}

public void Get5_OnRoundStatsUpdated(const Get5RoundStatsUpdatedEvent event) {
  if (Get5_GetGameState() == Get5State_Live) {
     UpdateRoundStats(event.MapNumber);
  }
}

float GetCurrentMatchRestartDelay() {
  ConVar mp_match_restart_delay = FindConVar("mp_match_restart_delay");
  if (mp_match_restart_delay == INVALID_HANDLE) {
    return 1.0;  // Shouldn't really be possible, but as a safeguard.
  }
  return mp_match_restart_delay.FloatValue;
}

 
public Action FreeServer(Handle timer)
{
  Handle req = CreateRequest(k_EHTTPMethodPOST, "freeserver");
  if (req != INVALID_HANDLE) {
    SteamWorks_SendHTTPRequest(req);
  }
  delete req;

  g_APIKeyCvar.SetString("");
}
