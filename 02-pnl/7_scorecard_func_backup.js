function getPosAct1() {
    apex.server.process(
        "GET_POSACT1",
        {
            x01: $v("P2000_PERIOD_FROM"),
            x02: $v("P2000_PERIOD_TO"),
            x03: $v("P2000_KC"),
            x04: $v("P2000_CABANG")
        },
        {
            success: function (data) {

                let html = '';

                if (!data || data.length === 0) {
                    $("#pos-act-list1").html(`
                        <div class="wrapper">
                            <div class="header" style="text-align: right;">
                                <div class="h-title white"></div>
                                <div class="h-value white"></div>
                            </div>
                        </div>
                    `);
                    return;
                }


                data.forEach(item => {
                    const minNA = item.minimum_portofolio?.trim() == 'N/A';
                    const minPortNA = item.minimum_portofolio?.trim() == 'Portfolio split N/A';
                    const gapNA = item?.gap?.trim() === 'N/A';
                    const gapNull = item?.gap == null;
                    const isHeader = item.is_header == 'Y';

                    // style
                    const minbgHeader = !isHeader ? (minNA  ? 'gray' : 'white') : 'donker';
                    const minTxt = !isHeader 
                                ? ( (minPortNA || minNA) ? '#9d9d9d' : 'black') 
                                : ( isHeader && minNA) ? '#9d9d9d': 'white'; 
                    const gapbgHeader =
                            (!gapNA && !gapNull)
                                ? 'green'
                                : (isHeader && gapNA)
                                    ? 'donker'
                                    : gapNA
                                        ? 'gray'
                                        : 'white';
                    const gapTxt = gapbgHeader == 'green' ? 'white' : '#9d9d9d';
                    const centerTxt = minNA || gapNA ? 'center' : 'right';

                    html += `
                        <div class="wrapper">
                            <div class="header" style="text-align: right; background: white !important;">
                                <div class="h-title ${minbgHeader}" style="color: ${minTxt}; text-align: ${centerTxt};">
                                    ${formatNumber(item.minimum_portofolio) || ' '}
                                </div>
                                <div class="h-value ${gapbgHeader}" style="color: ${gapTxt}; text-align: ${centerTxt};">
                                    ${formatNumber(item.gap) || ' '}
                                </div>
                            </div>
                        </div>
                    `;
                });

                $("#pos-act-list1").html(html);
            },
            error: function (jqXHR, textStatus, errorThrown) {
                console.error(textStatus, errorThrown);
            }
        }
    );
}
getPosAct1();

function getPosAct2() {
    apex.server.process(
        "GET_POSACT2",
        {
            x01: $v("P2000_PERIOD_FROM"),
            x02: $v("P2000_PERIOD_TO"),
            x03: $v("P2000_KC"),
            x04: $v("P2000_CABANG")
        },
        {
            success: function(data) {
                console.log(data, "data");
                if (!data || data.length === 0) {
                    $("#pos-act-list2").html(`
                        <div class="wrapper">
                            <div class="header" style="text-align: right;">
                                <div class="h-title white"> </div>
                                <div class="h-value white"> </div>
                            </div>
                        </div>
                    `);
                    return;
                }

                let html = '';

                data.forEach(item => {
                    const isHeader = item.is_header == 'Y';
                    // const maxNA = item.maximum_cost?.trim() == 'N/A';
                    const interNA = item.intervension?.includes('N/A');
                    const interMax = item.intervension?.includes('Max');
                    const interAs = item.intervension?.includes('As-Is');

                //    const maxBg = !isHeader ? (maxNA  ? 'gray' : 'white') : 'donker';
                    const maxBg = isHeader ? 'donker' : 'white';
                    const maxTxt = isHeader ? 'white' : 'black';
                    const interBg = interMax ? 'orange'
                                    : interAs ? 'green'
                                    : isHeader ? 'donker' 
                                    : 'white';
                    const interTxt = interBg == 'white' ? 'black' : 'white';

                    html += `
                        <div class="wrapper">
                            <div class="header" style="text-align: right;">
                                <div class="h-title ${maxBg}" style="color: ${maxTxt}">
                                     ${formatNumber(item.maximum_cost) || ' '}
                                </div>
                                <div class="h-value ${interBg}" style="color: ${interTxt}; text-align: left;">
                                    ${formatNumber(item.intervension) || ' '}
                                </div>
                            </div>
                        </div>
                    `;
                });

                $("#pos-act-list2").html(html);
            },
            error: function(jqXHR, textStatus, errorThrown){
                // console.log("ERROR");
                // console.log(jqXHR.responseText);
                // console.log(textStatus);
                // console.log(errorThrown);
            }
        }
    );
}
getPosAct2();

function getPosAct3() {
    apex.server.process(
        "GET_POSACT3",
        {
            x01: $v("P2000_PERIOD_FROM"),
            x02: $v("P2000_PERIOD_TO"),
            x03: $v("P2000_KC"),
            x04: $v("P2000_CABANG")
        },
        {
            success: function(data) {
                if (!data || data.length === 0) {
                    $("#pos-act-list3").html(`
                        <div class="wrapper">
                            <div class="header" style="text-align: right;">
                                <div class="h-title white"></div>
                                <div class="h-value white"></div>
                            </div>
                        </div>
                    `);
                    return;
                }

                let html = '';

                data.forEach(item => {

                    const maxBg = isHeader ? 'donker' : 'white';
                    const maxTxt = isHeader ? 'white' : 'black';
                    const interBg = interMax ? 'orange'
                                    : interAs ? 'green'
                                    : isHeader ? 'donker' 
                                    : 'white';
                    const interTxt = interBg == 'white' ? 'black' : 'white';

                    html += `
                        <div class="wrapper">
                            <div class="header" style="text-align: right;">
                                <div class="h-title ${maxBg}" style="color: ${maxTxt}">
                                     ${formatNumber(item.maximum_cost) || ' '}
                                </div>
                                <div class="h-value ${interBg}" style="color: ${interTxt}; text-align: left;">
                                    ${formatNumber(item.intervension) || ' '}
                                </div>
                            </div>
                        </div>
                    `;
                });

                $("#pos-act-list3").html(html);
            },
            error: function(jqXHR, textStatus, errorThrown){
                // console.log("ERROR");
                // console.log(jqXHR.responseText);
                // console.log(textStatus);
                // console.log(errorThrown);
            }
        }
    );
}
getPosAct3();




function getHeaderInfo() {

    apex.server.process(
        "GET_HEADER_INFO",
        {
            x01: $v("P2000_PERIOD_FROM"),
            x02: $v("P2000_PERIOD_TO"),
            x03: $v("P2000_KC"),
            x04: $v("P2000_CABANG")
        },
        {
            dataType: "json",
            success: function(data) {
                // console.log(data, "data header info")
                if (data.error) {
                    console.log(data.error);
                    return;
                }

                $("#cabang").text(data.cabang || "-");
                // $("#kategori_lokasi").text(data.kategori_lokasi || "-");
                // $("#kelas_cabang").text(data.kelas_cabang || "-");
                $("#interest_income").text(data.interest_income || "-");
                $("#cost_of_fund").text(data.cost_of_fund || "-");
                $("#kredit_portofolio").text(data.kredit_portofolio || "-");
                // $("#avg_manpower").text(data.avg_manpower || "-");
                $("#minimum-nii").text(formatNumber(data.minimum_nii) || "-");
                $("#total_income").text(formatNumber(data.total_income) || "-");
                $("#total_ppop").text(formatNumber(data.total_ppop) || "-");
            }
        }
    );
}
getHeaderInfo();

function loadDataList() {

    apex.server.process(
        "GET_LIST",
        {
            x01: $v("P2000_PERIOD_FROM"),
            x02: $v("P2000_PERIOD_TO"),
            x03: $v("P2000_KC"),
            x04: $v("P2000_CABANG")
        },
        {
            success: function(data) {
                if (!data || data.length === 0) {
                    $("#loop-data-list").html(`
                        <div class="wrapper">
                            <div class="header">
                                <div class="h-title donker"> </div>
                                <div class="h-value donker" style="text-align: right;"></div>
                            </div>

                            <div class="menu">
                                <ul class="b-title"></ul>
                                <ul class="b-value white-bold"></ul>
                            </div>

                        </div>
                    `);
                    return;
                }

                // fungsi format number general = call function formatNumber()
                // grouping by group_number
                const groups = {};

                data.forEach(item => {
                    if(!groups[item.group_number]){
                        groups[item.group_number] = [];
                    }
                    groups[item.group_number].push(item);
                });

                const sortedKeys = Object.keys(groups).sort((a,b)=>a-b);

                let html = '';

                sortedKeys.forEach(key => {

                    const group = groups[key];

                    let headerName = '';
                    let headerAmount = '';

                    let titles = [];
                    let values = [];

                    group.forEach(row => {
                        if(row.is_header === 'Y'){
                            headerName = row.column_name;
                            headerAmount = row.nominal;
                        } else {
                            titles.push({
                                title: row.column_name,
                                isLines: row.is_lines
                            });
                            // titles.push(row.column_name);
                            values.push(row.nominal);
                        }

                        isLines = row.is_lines;
                    });

                    html += `
                        <div class="wrapper">
                            <div class="header">
                                <div class="h-title donker">
                                    ${apex.util.escapeHTML(headerName)}
                                </div>
                                <div class="h-value donker" style="text-align: right;">
                                    ${formatNumber(headerAmount)}
                                </div>
                            </div>

                            <div class="menu">
                                <ul class="b-title">
                                    ${titles.map(item => `
                                        <li style="background-color:${
                                            item.isLines === 'Y'
                                                ? '#dae9f8'
                                                : '#a6c9ec'
                                        };">
                                            ${apex.util.escapeHTML(item.title)}
                                        </li>
                                    `).join('')}
                                </ul>

                                <ul class="b-value white-bold">
                                    ${values.map(v => `<li>${formatNumber(v)}</li>`).join('')}
                                </ul>
                            </div>

                        </div>
                    `;
                });

                $("#loop-data-list").html(html);
            },
            error: function(jqXHR, textStatus, errorThrown){
                // console.log("ERROR");
                // console.log(jqXHR.responseText);
                // console.log(textStatus);
                // console.log(errorThrown);
            }
        }
    );
}
loadDataList();

function updatePeriodText() {

    // FORCE ambil value terbaru dari DOM (bukan cache APEX)
    var from = apex.item("P2000_PERIOD_FROM").getValue();
    var to   = apex.item("P2000_PERIOD_TO").getValue();

    // console.log("FROM:", from, "TO:", to);

    if (!from || !to) {
        $("#period_text").html("Periode berjalan: - · - hari");
        return;
    }

    apex.server.process("GET_PERIOD_INFO", {
        x01: from,
        x02: to
    }, {
        dataType: "json",
        success: function(res) {

            $("#period_text").html(
                "Periode berjalan: " + from + " - " + to + " · " + res.days
            );

            apex.item("P2000_COUNT_DAYS").setValue(res.days);

        }
    });
}
updatePeriodText();

function calcTotalDays() {

    var from = apex.item("P2000_PERIOD_FROM").getValue();
    var to   = apex.item("P2000_PERIOD_TO").getValue();

    if (!from || !to) {
        apex.item("P2000_TOTAL_DAYS").setValue("");
        return;
    }

    var d1 = new Date(from);
    var d2 = new Date(to);

    var diffTime = d2 - d1;
    var diffDays = Math.floor(diffTime / (1000 * 60 * 60 * 24)) + 1;

    apex.item("P2000_TOTAL_DAYS").setValue(diffDays + " hari");
}


let isRestoring = false;

function saveFiltersToLocal() {
    if (isRestoring) return;

    sessionStorage.setItem("P2000_PERIOD_FROM", apex.item("P2000_PERIOD_FROM").getValue());
    sessionStorage.setItem("P2000_PERIOD_TO", apex.item("P2000_PERIOD_TO").getValue());
    sessionStorage.setItem("P2000_KC", apex.item("P2000_KC").getValue());
    sessionStorage.setItem("P2000_CABANG", apex.item("P2000_CABANG").getValue());
}

function restoreFilters() {

    isRestoring = true;

    apex.item("P2000_PERIOD_FROM")
        .setValue(sessionStorage.getItem("P2000_PERIOD_FROM"));

    $("#P2000_PERIOD_TO")
        .val(sessionStorage.getItem("P2000_PERIOD_TO"))
        .trigger("change");

    apex.item("P2000_KC")
        .setValue(sessionStorage.getItem("P2000_KC"));

    apex.item("P2000_CABANG")
        .setValue(sessionStorage.getItem("P2000_CABANG"));

    setTimeout(() => {
        isRestoring = false;
    }, 1000);
}



// ----------------------------------LOCAL STORAGE------------------------
// function saveFiltersToLocal() {
//     if (isRestoring) return;
//     localStorage.setItem("P2000_PERIOD_FROM", apex.item("P2000_PERIOD_FROM").getValue());
//     localStorage.setItem("P2000_PERIOD_TO", apex.item("P2000_PERIOD_TO").getValue());
//     localStorage.setItem("P2000_KC", apex.item("P2000_KC").getValue());
//     localStorage.setItem("P2000_CABANG", apex.item("P2000_CABANG").getValue());
// }

// function restoreFilters() {

//     isRestoring = true;

//     apex.item("P2000_PERIOD_FROM")
//         .setValue(localStorage.getItem("P2000_PERIOD_FROM"));

//     $("#P2000_PERIOD_TO")
//         .val(localStorage.getItem("P2000_PERIOD_TO"))
//         .trigger("change");

//     apex.item("P2000_KC").setValue(localStorage.getItem("P2000_KC"));

//     apex.item("P2000_CABANG").setValue(localStorage.getItem("P2000_CABANG"));

//     setTimeout(() => {
//         isRestoring = false;
//     }, 1000);
// }

