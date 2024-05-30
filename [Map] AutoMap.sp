#pragma semicolon 1
#pragma newdecls required

#include <sourcemod>

#define LOS 	0 			/* 失败团灭 */
#define WIN 	1 			/* 终章通关 */
#define SEC 	5			/* 换图时间 团灭换图执行时间必须短，所以...... */
#define LIM 	3			/* 任意章节团灭多少次后换图 */

static char MapInfo[][][64] =
{
	/* StartMap-0			FinaleMap-1					StartMapName-2 */
	{"c1m1_hotel"			,"c1m4_atrium"				,"c1-死亡中心"},
	{"c2m1_highway"			,"c2m5_concert"				,"c2-黑色狂欢节"},
	{"c3m1_plankcountry"	,"c3m4_plantation"			,"c3-沼泽激战"},
	{"c4m1_milltown_a"		,"c4m5_milltown_escape"		,"c4-暴风骤雨"},
	{"c5m1_waterfront"		,"c5m5_bridge"				,"c5-教区"},
	{"c6m1_riverbank"		,"c6m3_port"				,"c6-短暂时刻"},
	{"c7m1_docks"			,"c7m3_port"				,"c7-牺牲"},
	{"c8m1_apartment"		,"c8m5_rooftop"				,"c8-毫不留情"},
	{"c9m1_alleys"			,"c9m2_lots"				,"c9-坠机险途"},
	{"c10m1_caves"			,"c10m5_houseboat"			,"c10-死亡丧钟"},
	{"c11m1_greenhouse"		,"c11m5_runway"				,"c11-静寂时分"},
	{"c12m1_hilltop"		,"c12m5_cornfield"			,"c12-血腥收获"},
	{"c13m1_alpinecreek"	,"c13m4_cutthroatcreek"		,"c13-刺骨寒溪"},
	{"c14m1_junkyard"		,"c14m2_lighthouse"			,"c14-临死一搏"}
};

static int Count;

public Plugin myinfo =
{
	name		= "地图|自动换图",
	description = "-",
	author		= "Ryanx, 24の节气",
	version		= "2.B",
	url			= "-"
};

public void OnPluginStart()
{
	HookEvent("finale_win",		Event_Win);
	HookEvent("mission_lost",	Event_Los);
}
public void OnMapStart() {Count = 0;}

void Event_Win(Event event, const char[] name, bool dontBroadcast) {CheckMap(WIN, SEC);}
void Event_Los(Event event, const char[] name, bool dontBroadcast) 
{
	Count ++;
	if(Count == LIM) CheckMap(LOS, LIM);
}

void CheckMap(int type, int data)
{
	int e = -1;
	static int maxindex = sizeof MapInfo - 1;

	char map[128];
	GetCurrentMap(map, sizeof map);

	/* 和官方最终章节地图名列表匹配 若是官图c14m2 换官图c1m1 */
	for(int i; i <= maxindex; i++)
	{
		if(strcmp(map, MapInfo[i][1], false) == 0)
		{
			e = (i == maxindex ? 0 : i + 1);

			break;
		}
	}

	int mapnum = (e == -1 ? GetRandomInt(0, maxindex) : e);

	PrintToChatAll((type ? "\x04自动换图 | \x05%d秒\n\x04下一章节 | \x05%s" : "\x04团灭次数 | \x05%d次\n\x04下一章节 | \x05%s"), data, MapInfo[mapnum][2]);

	CreateTimer(float(SEC), Timer_ChangeMap, mapnum);
}

Action Timer_ChangeMap(Handle timer, int num) {ServerCommand("changelevel %s", MapInfo[num][0]); return Plugin_Continue;}