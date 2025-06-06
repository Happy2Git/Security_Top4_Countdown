# TOP4 countdown widget — now with proper AoE (UTC−12) time logic

refreshFrequency: 1000
command: "./top4_fetch.sh"

style: """
  width: auto;
  height: auto;
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  
  .confBlock {
    font-family: 'DK Crayon Crumble', serif;
    text-align: center;
    color: white;
    margin-bottom: 25px;
  }

  .confName {
    font-size: 30px;
    font-weight: bold;
  }

  .countdown {
    font-size: 24px;
    margin-top: 5px;
  }

  .confMeta {
    font-size: 16px;
    margin-top: 2px;
    color: #ccc;
  }
"""

render: (output) -> """
  <div class="confWrapper"></div>
"""

update: (output, domEl) ->
  dom = $(domEl)
  wrapper = dom.find(".confWrapper")
  wrapper.empty()

  try
    data = JSON.parse(output)
    now = new Date()
    pad = (n) -> if n < 10 then "0" + n else n

    top4 = data.filter((c) -> c.tags?.includes("TOP4"))

    for conf in top4
      # Create Date objects in UTC and shift to AoE by subtracting 12h
      deadlines = (conf.deadline or []).map((d, i) ->
        dUTC = new Date(d.replace(" ", "T") + ":00Z")  # force UTC parsing
        dAoE = new Date(dUTC.getTime() - 12 * 60 * 60 * 1000)
        {
          label: "Cycle #{i + 1}",
          deadline: dAoE
        })

      nextCycle = deadlines.find((dl) -> dl.deadline > now)

      if nextCycle
        diff = nextCycle.deadline - now
        days = Math.floor(diff / (1000 * 60 * 60 * 24))
        hours = Math.floor(diff / (1000 * 60 * 60)) % 24
        minutes = Math.floor(diff / (1000 * 60)) % 60
        seconds = Math.floor(diff / 1000) % 60
        timeStr = "#{nextCycle.label}: #{days}d #{pad(hours)}h #{pad(minutes)}m #{pad(seconds)}s"
      else
        timeStr = "All cycles passed"

      wrapper.append("""
        <div class="confBlock">
          <div class="confName">#{conf.name}’#{String(conf.year).slice(-2)}</div>
          <div class="countdown">#{timeStr}</div>
          <div class="confMeta">#{conf.place} — #{conf.date}</div>
        </div>
      """)

  catch error
    wrapper.html("<div style='color:red;'>Error loading data</div>")

  ''
