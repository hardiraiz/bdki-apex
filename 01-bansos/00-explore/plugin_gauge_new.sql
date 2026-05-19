/****************************************************************************************

 --  Plugin      : APEX_KPI_GAUGE
 --  InternalName: IR.APEX_KPI_GAUGE
 --  Author      : Morteza Mashhadi
 --  Editor      : M. Hardi Raiz
 --  Create Date : Friday - 2019 25 January
 --  Update Date : Tuesday - 2026 5 May
 --  Version     : 1.1
 --  Description : Key performance indicator gauge for Oracle APEX
 --  Website     : www.mortezamashhadi.blogspot.com

 ****************************************************************************************/


FUNCTION kpi_gauge (
    P_REGION              IN APEX_PLUGIN.T_REGION,
    P_PLUGIN              IN APEX_PLUGIN.T_PLUGIN,
    P_IS_PRINTER_FRIENDLY IN BOOLEAN )
  RETURN APEX_PLUGIN.T_REGION_RENDER_RESULT
IS

gaugeName       varchar(20) := 'kpiGauge' || p_region.attribute_01;
gaugePoint      number:= 0;
startPoint      number:= 0;
endPoint        number:= 100;
endDarkGreen    number:= 20;
endGreen        number:= 40;
endYellow       number:= 60;
endOrange       number:= 80;
endRed          number:= 100;

l_column_value apex_plugin_util.t_column_value_list;

--attributes
angle               number      := nvl(p_region.attribute_02,0);
lineWidth           number      := nvl(p_region.attribute_03,0.4);
radiusScale         number      := nvl(p_region.attribute_04,0.8);
pointerLength       number      := nvl(p_region.attribute_05,0.45);
pointerStrokeWidth  number      := nvl(p_region.attribute_06,0.03);
pointerColor        varchar(20) := nvl(p_region.attribute_07,'#7f7f7f');

--renderTicks
divisions       number      :=  nvl(p_region.attribute_08,5);
divWidth        number      :=  nvl(p_region.attribute_09,1.1);
divLength       number      :=  nvl(p_region.attribute_10,0.7);
divColor        varchar(20) :=  nvl(p_region.attribute_11,'#333333');
subDivisions    number      :=  nvl(p_region.attribute_12,3);
subLength       number      :=  nvl(p_region.attribute_13,0.5);
subWidth        number      :=  nvl(p_region.attribute_14,0.6);
subColor        varchar(20) :=  nvl(p_region.attribute_15,'#666666');

begin
    apex_javascript.add_library (
        p_name      => 'apex_kpi_gauge',
        p_directory => p_plugin.file_prefix,
        p_version   => null );

    l_column_value := APEX_PLUGIN_UTIL.GET_DATA (
        p_sql_statement    => P_REGION.source,
        p_min_columns      => 1,
        p_max_columns      => 8,
        p_component_name   => P_REGION.NAME,
        p_search_type      => NULL,
        p_search_column_no => NULL,
        p_search_string    => NULL,
        p_first_row        => NULL,
        p_max_rows         => 1);

    -- Kolom 1 wajib ada (gaugePoint)
    gaugePoint := to_number(apex_escape.html(l_column_value(1)(1)));

    -- Kolom 2-8 opsional, cek jumlah kolom dulu sebelum akses
    if l_column_value.count >= 2 then
        startPoint   := nvl(to_number(apex_escape.html(l_column_value(2)(1))), startPoint);
    end if;

    if l_column_value.count >= 3 then
        endPoint     := nvl(to_number(apex_escape.html(l_column_value(3)(1))), endPoint);
    end if;

    if l_column_value.count >= 4 then
        endDarkGreen := nvl(to_number(apex_escape.html(l_column_value(4)(1))), endDarkGreen);
    end if;

    if l_column_value.count >= 5 then
        endGreen     := nvl(to_number(apex_escape.html(l_column_value(5)(1))), endGreen);
    end if;

    if l_column_value.count >= 6 then
        endYellow    := nvl(to_number(apex_escape.html(l_column_value(6)(1))), endYellow);
    end if;

    if l_column_value.count >= 7 then
        endOrange    := nvl(to_number(apex_escape.html(l_column_value(7)(1))), endOrange);
    end if;

    if l_column_value.count >= 8 then
        endRed       := nvl(to_number(apex_escape.html(l_column_value(8)(1))), endRed);
    end if;

    sys.htp.p('
              <div style="width:100%; text-align:center">
                <canvas width=400 height=150 id="'||gaugeName||'" ></canvas>
                <div id="'||gaugeName||'-textfield" style="margin: 0px auto;
                text-align: center;
                font-size: 18px;
                font-weight: bold;"></div>
              </div>
    ');

    apex_javascript.add_onload_code(
        gaugeName||' = new Gauge(document.getElementById("'||gaugeName||'"));
        var opts = {
          angle: '||angle||',
          lineWidth: '||lineWidth||',
          radiusScale:'||radiusScale||',
          pointer: {
            length: '||pointerLength||',
            strokeWidth: '||pointerStrokeWidth||',
            color: "'||pointerColor||'"
          },
          renderTicks: {
              divisions: '||divisions||',
              divWidth: '||divWidth||',
              divLength: '||divLength||',
              divColor: "'||divColor||'",
              subDivisions: '||subDivisions||',
              subLength: '||subLength||',
              subWidth: '||subWidth||',
              subColor: "'||subColor||'"
            },
          staticLabels: {
            font: "10px sans-serif",
            labels: [
                {value: '||((startPoint   + endDarkGreen) / 2)||', label: "Level 1"},
                {value: '||((endDarkGreen + endGreen)     / 2)||', label: "Level 2"},
                {value: '||((endGreen     + endYellow)    / 2)||', label: "Level 3"},
                {value: '||((endYellow    + endOrange)    / 2)||', label: "Level 4"},
                {value: '||((endOrange    + endPoint)     / 2)||', label: "Level 5"}
            ],
            fractionDigits: 0
          },
          staticZones: [
             {strokeStyle: "#55bf3b", min: '||startPoint||',    max: '||endDarkGreen||'},
             {strokeStyle: "#9acd32", min: '||endDarkGreen||',  max: '||endGreen||'},
             {strokeStyle: "#dfdf0d", min: '||endGreen||',      max: '||endYellow||'},
             {strokeStyle: "#fea500", min: '||endYellow||',     max: '||endOrange||'},
             {strokeStyle: "#de5454", min: '||endOrange||',     max: '||endPoint||'}
          ],
          limitMax: false,
          limitMin: false,
          highDpiSupport: true
        };
        '||gaugeName||'.setOptions(opts);
        '||gaugeName||'.setTextField(document.getElementById("'||gaugeName||'-textfield"));
        '||gaugeName||'.minValue = '||startPoint||';
        '||gaugeName||'.maxValue = '||endPoint||';
        '||gaugeName||'.set('||gaugePoint||');
    ');

return null;

end kpi_gauge;