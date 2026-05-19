/****************************************************************************************

 --  Plugin      : APEX_KPI_GAUGE
 --  InternalName: IR.APEX_KPI_GAUGE
 --  Author      : Morteza Mashhadi
 --  Create Date : Friday - 2019 25 January
 --  Version     : 1.0
 --  Description : Key performance indicator gauge for Oracle APEX
 --  Website     : www.mortezamashhadi.blogspot.com

 ****************************************************************************************/


FUNCTION kpi_gauge (
    P_REGION              IN APEX_PLUGIN.T_REGION,
    P_PLUGIN              IN APEX_PLUGIN.T_PLUGIN,
    P_IS_PRINTER_FRIENDLY IN BOOLEAN )
  RETURN APEX_PLUGIN.T_REGION_RENDER_RESULT
IS

gaugeName varchar(20):='kpiGauge'||p_region.attribute_01;
gaugePoint number:=0;
startPoint number:=0;
endPoint number:=100;
startYellow number:=20;
startGreen number:=80;
l_column_value apex_plugin_util.t_column_value_list;

--attributes
angle number:=nvl(p_region.attribute_02,0.12);
lineWidth number:=nvl(p_region.attribute_03,0.18);
radiusScale number:=nvl(p_region.attribute_04,0.99);
pointerLength number:=nvl(p_region.attribute_05,0.45);
pointerStrokeWidth number:=nvl(p_region.attribute_06,0.05);
pointerColor varchar(20):=nvl(p_region.attribute_07,'#000000');

--renderTicks
divisions number:=nvl(p_region.attribute_08,5);
divWidth number:=nvl(p_region.attribute_09,1.1);
divLength number:=nvl(p_region.attribute_10,0.7);
divColor varchar(20):=nvl(p_region.attribute_11,'#333333');
subDivisions number:=nvl(p_region.attribute_12,3);
subLength number:=nvl(p_region.attribute_13,0.5);
subWidth number:=nvl(p_region.attribute_14,0.6);
subColor varchar(20):=nvl(p_region.attribute_15,'#666666');

begin


    --add javascript files
    apex_javascript.add_library (
        p_name      => 'apex_kpi_gauge',
        p_directory => p_plugin.file_prefix,
        p_version   => null );


    l_column_value := APEX_PLUGIN_UTIL.GET_DATA (
        p_sql_statement    => P_REGION.source ,
        p_min_columns      => 5,
        p_max_columns      => 5,
        p_component_name   => P_REGION.NAME,
        p_search_type      => NULL,
        p_search_column_no => NULL,
        p_search_string    => NULL,
        p_first_row        => NULL,
        p_max_rows         => 1);

    --Get value and Label from Query
        gaugePoint := apex_escape.html(l_column_value(1)(1));
        startPoint := apex_escape.html(l_column_value(2)(1));
        endPoint := apex_escape.html(l_column_value(3)(1));
        startYellow := apex_escape.html(l_column_value(4)(1));
        startGreen := apex_escape.html(l_column_value(5)(1));

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
            labels: ['||startPoint||','||startYellow||', '||startGreen||','||endPoint||'],
            fractionDigits: 0
          },
          staticZones: [
             {strokeStyle: "#F03E3E", min: '||startPoint||', max: '||startYellow||'},
             {strokeStyle: "#FFDD00", min: '||startYellow||', max: '||startGreen||'},
             {strokeStyle: "#30B32D", min: '||startGreen||', max: '||endPoint||'}
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

end;