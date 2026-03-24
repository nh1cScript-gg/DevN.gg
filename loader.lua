<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>DevN.gg UI v4.4 — Redesigned</title>
<link href="https://fonts.googleapis.com/css2?family=Syne:wght@400;600;700;800&family=JetBrains+Mono:wght@400;500&family=Inter:wght@300;400;500;600&display=swap" rel="stylesheet"/>
<style>
  :root {
    --navy:       #021a50;
    --navy-mid:   #041e64;
    --dark:       #03112a;
    --hdr:        #020e38;
    --border:     rgba(100,148,255,0.25);
    --border-foc: rgba(168,207,255,0.7);
    --txt-a:      #ffffff;
    --txt-b:      #c8dcff;
    --txt-c:      #7a9fd4;
    --accent:     #a8cfff;
    --tog-on:     #6fffa0;
    --tog-on-bg:  rgba(10,60,30,0.9);
    --tog-off-bg: rgba(8,14,38,0.9);
    --hov:        rgba(20,55,130,0.5);
    --act:        rgba(35,80,170,0.6);
    --red:        #ff7070;
    --amber:      #ffc84a;
    --glass:      rgba(4,22,74,0.52);
    --glass-side: rgba(3,18,60,0.60);
    --shadow:     0 24px 80px rgba(0,0,0,0.7), 0 4px 20px rgba(0,4,30,0.5);
    --radius:     14px;
    --radius-sm:  8px;
  }

  *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

  body {
    background: radial-gradient(ellipse at 30% 40%, #0b1e5c 0%, #040d24 60%, #000510 100%);
    min-height: 100vh;
    display: flex;
    align-items: center;
    justify-content: center;
    font-family: 'Inter', sans-serif;
    overflow: hidden;
  }

  /* Stars bg */
  body::before {
    content:'';
    position:fixed;inset:0;
    background-image:
      radial-gradient(1px 1px at 12% 18%, rgba(180,210,255,0.5) 0%, transparent 100%),
      radial-gradient(1px 1px at 55% 7%,  rgba(180,210,255,0.4) 0%, transparent 100%),
      radial-gradient(1.5px 1.5px at 72% 34%, rgba(180,210,255,0.35) 0%, transparent 100%),
      radial-gradient(1px 1px at 91% 62%, rgba(180,210,255,0.3) 0%, transparent 100%),
      radial-gradient(1px 1px at 37% 82%, rgba(180,210,255,0.4) 0%, transparent 100%),
      radial-gradient(1px 1px at 20% 70%, rgba(180,210,255,0.25) 0%, transparent 100%);
    pointer-events:none;z-index:0;
  }

  /* ═══════════════ WINDOW ═══════════════ */
  .window {
    position: relative;
    display: flex;
    width: 720px;
    height: 480px;
    background: transparent;
    border-radius: var(--radius);
    box-shadow: var(--shadow);
    border: 1px solid var(--border);
    overflow: visible;
    z-index: 10;
    animation: fadeIn .35s ease both;
  }
  @keyframes fadeIn { from { opacity:0; transform:scale(.96) translateY(8px); } to { opacity:1; transform:none; } }

  /* ═══════════════ SIDEBAR ═══════════════ */
  .sidebar {
    width: 165px;
    min-width: 165px;
    background: var(--glass-side);
    backdrop-filter: blur(20px) saturate(180%);
    -webkit-backdrop-filter: blur(20px) saturate(180%);
    border-right: 1px solid var(--border);
    border-radius: var(--radius) 0 0 var(--radius);
    display: flex;
    flex-direction: column;
    overflow: hidden;
  }

  .sidebar-header {
    padding: 20px 14px 14px;
    border-bottom: 1px solid var(--border);
    flex-shrink: 0;
    cursor: move;
    user-select: none;
  }
  .sidebar-logo {
    font-family: 'Syne', sans-serif;
    font-weight: 800;
    font-size: 17px;
    color: var(--txt-a);
    letter-spacing: -.3px;
    line-height: 1;
  }
  .sidebar-version {
    font-family: 'JetBrains Mono', monospace;
    font-size: 10px;
    color: var(--txt-c);
    margin-top: 4px;
    letter-spacing: .5px;
  }

  .sidebar-nav {
    flex: 1;
    overflow-y: auto;
    padding: 10px 8px;
    display: flex;
    flex-direction: column;
    gap: 2px;
    scrollbar-width: thin;
    scrollbar-color: rgba(168,207,255,0.2) transparent;
  }
  .sidebar-nav::-webkit-scrollbar { width: 3px; }
  .sidebar-nav::-webkit-scrollbar-thumb { background: rgba(168,207,255,0.25); border-radius: 99px; }

  .tab-btn {
    display: flex;
    align-items: center;
    gap: 9px;
    padding: 9px 10px;
    border-radius: var(--radius-sm);
    cursor: pointer;
    transition: background .15s, color .15s;
    border: none;
    background: transparent;
    width: 100%;
    text-align: left;
    color: var(--txt-c);
    font-family: 'Inter', sans-serif;
    font-size: 13px;
    font-weight: 500;
    position: relative;
  }
  .tab-btn:hover { background: var(--hov); color: var(--txt-b); }
  .tab-btn.active {
    background: rgba(255,255,255,0.95);
    color: var(--navy);
    font-weight: 600;
  }
  .tab-btn.active .tab-icon { color: var(--navy); }
  .tab-icon {
    font-size: 15px;
    width: 18px;
    text-align: center;
    flex-shrink: 0;
    transition: color .15s;
  }

  .sidebar-footer {
    padding: 10px;
    border-top: 1px solid var(--border);
    font-size: 10px;
    color: var(--txt-c);
    text-align: center;
    font-family: 'JetBrains Mono', monospace;
    letter-spacing: .5px;
    flex-shrink: 0;
  }

  /* ═══════════════ CONTENT ═══════════════ */
  .content {
    flex: 1;
    background: var(--glass);
    backdrop-filter: blur(24px) saturate(160%);
    -webkit-backdrop-filter: blur(24px) saturate(160%);
    border-radius: 0 var(--radius) var(--radius) 0;
    display: flex;
    flex-direction: column;
    overflow: hidden;
  }

  .content-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 16px;
    height: 50px;
    border-bottom: 1px solid var(--border);
    flex-shrink: 0;
    cursor: move;
    user-select: none;
  }
  .content-title {
    font-family: 'Syne', sans-serif;
    font-size: 16px;
    font-weight: 700;
    color: var(--txt-a);
    letter-spacing: -.3px;
  }

  .win-controls { display: flex; gap: 6px; }
  .win-btn {
    width: 26px; height: 26px;
    border-radius: 6px;
    border: 1px solid var(--border);
    background: rgba(4,22,74,0.5);
    color: var(--txt-c);
    font-size: 14px;
    line-height: 1;
    cursor: pointer;
    transition: background .15s, color .15s, border-color .15s;
    display: flex; align-items: center; justify-content: center;
  }
  .win-btn:hover { background: var(--hov); }
  .win-btn.close:hover { color: var(--red); border-color: var(--red); }
  .win-btn.min:hover   { color: var(--amber); border-color: var(--amber); }

  .content-body {
    flex: 1;
    overflow-y: auto;
    padding: 18px 18px 18px;
    scrollbar-width: thin;
    scrollbar-color: rgba(168,207,255,0.2) transparent;
  }
  .content-body::-webkit-scrollbar { width: 4px; }
  .content-body::-webkit-scrollbar-thumb { background: rgba(168,207,255,0.2); border-radius: 99px; }

  /* ═══════════════ TAB PANEL ═══════════════ */
  .tab-panel { display: none; flex-direction: column; gap: 6px; }
  .tab-panel.active { display: flex; }

  /* Section label */
  .section-label {
    font-family: 'Syne', sans-serif;
    font-size: 11px;
    font-weight: 700;
    color: var(--txt-c);
    letter-spacing: 1.5px;
    text-transform: uppercase;
    padding: 10px 0 4px;
  }
  .section-label:first-child { padding-top: 0; }

  /* ═══════════════ ROWS ═══════════════ */
  .row {
    display: flex;
    align-items: center;
    justify-content: space-between;
    background: rgba(5,18,60,0.55);
    border: 1px solid rgba(80,120,210,0.25);
    border-radius: var(--radius-sm);
    padding: 10px 14px;
    gap: 12px;
    transition: background .15s, border-color .15s;
    min-height: 46px;
  }
  .row:hover { background: var(--hov); border-color: rgba(130,170,255,0.35); }
  .row-label {
    font-size: 13px;
    color: var(--txt-b);
    font-weight: 500;
    flex: 1;
    min-width: 0;
  }
  .row-label .sub {
    display: block;
    font-size: 10px;
    color: var(--txt-c);
    font-weight: 400;
    margin-top: 2px;
  }

  /* ═══════════════ TOGGLE ═══════════════ */
  .toggle-wrap { position: relative; width: 40px; height: 22px; flex-shrink: 0; }
  .toggle-wrap input { opacity:0; width:0; height:0; position:absolute; }
  .toggle-slider {
    position: absolute; inset: 0;
    background: var(--tog-off-bg);
    border: 1px solid rgba(80,120,210,0.4);
    border-radius: 99px;
    cursor: pointer;
    transition: background .2s, border-color .2s;
  }
  .toggle-slider::after {
    content:'';
    position: absolute;
    width: 16px; height: 16px;
    background: #7090c0;
    border-radius: 50%;
    top: 2px; left: 2px;
    transition: transform .2s, background .2s;
    box-shadow: 0 1px 4px rgba(0,0,0,0.4);
  }
  .toggle-wrap input:checked + .toggle-slider { background: var(--tog-on-bg); border-color: rgba(80,255,120,0.35); }
  .toggle-wrap input:checked + .toggle-slider::after { transform: translateX(18px); background: var(--tog-on); }

  /* ═══════════════ DROPDOWN ═══════════════ */
  .dropdown { position: relative; flex-shrink: 0; }
  .dropdown-btn {
    display: flex; align-items: center; gap: 8px;
    background: rgba(3,12,40,0.8);
    border: 1px solid rgba(80,120,210,0.35);
    border-radius: var(--radius-sm);
    padding: 7px 10px;
    color: var(--txt-b);
    font-size: 12px;
    font-family: 'Inter', sans-serif;
    cursor: pointer;
    transition: border-color .15s, background .15s;
    white-space: nowrap;
    min-width: 120px;
    justify-content: space-between;
    user-select: none;
  }
  .dropdown-btn:hover { border-color: var(--border-foc); background: rgba(10,30,80,0.8); }
  .dropdown-btn.open { border-color: var(--border-foc); background: rgba(10,30,80,0.9); }
  .dropdown-arrow { font-size: 10px; color: var(--txt-c); transition: transform .2s; flex-shrink: 0; }
  .dropdown-btn.open .dropdown-arrow { transform: rotate(180deg); }

  .dropdown-menu {
    position: absolute;
    top: calc(100% + 4px);
    right: 0;
    min-width: 100%;
    background: rgba(3,14,46,0.97);
    border: 1px solid var(--border-foc);
    border-radius: var(--radius-sm);
    box-shadow: 0 12px 40px rgba(0,0,0,0.6);
    z-index: 1000;
    overflow: hidden;
    display: none;
    flex-direction: column;
    backdrop-filter: blur(20px);
    animation: ddOpen .15s ease both;
  }
  @keyframes ddOpen { from { opacity:0; transform:translateY(-6px) scaleY(.9); } to { opacity:1; transform:none; } }
  .dropdown-menu.open { display: flex; }

  .dropdown-item {
    padding: 9px 12px;
    font-size: 12px;
    color: var(--txt-b);
    cursor: pointer;
    transition: background .1s, color .1s;
    white-space: nowrap;
    font-family: 'Inter', sans-serif;
  }
  .dropdown-item:hover { background: var(--hov); color: var(--txt-a); }
  .dropdown-item.selected { color: var(--accent); font-weight: 600; }

  /* ═══════════════ SLIDER ═══════════════ */
  .slider-wrap { display: flex; align-items: center; gap: 10px; flex-shrink: 0; width: 160px; }
  .slider-val {
    font-family: 'JetBrains Mono', monospace;
    font-size: 11px;
    color: var(--accent);
    width: 30px;
    text-align: right;
    flex-shrink: 0;
  }
  input[type=range] {
    -webkit-appearance: none;
    flex: 1;
    height: 4px;
    background: rgba(80,120,210,0.3);
    border-radius: 99px;
    outline: none;
    cursor: pointer;
  }
  input[type=range]::-webkit-slider-thumb {
    -webkit-appearance: none;
    width: 14px; height: 14px;
    background: var(--accent);
    border-radius: 50%;
    box-shadow: 0 0 8px rgba(168,207,255,0.5);
    transition: box-shadow .15s;
  }
  input[type=range]::-webkit-slider-thumb:hover { box-shadow: 0 0 14px rgba(168,207,255,0.8); }

  /* ═══════════════ BUTTON ═══════════════ */
  .action-btn {
    padding: 8px 18px;
    background: rgba(168,207,255,0.12);
    border: 1px solid rgba(168,207,255,0.3);
    border-radius: var(--radius-sm);
    color: var(--accent);
    font-size: 12px;
    font-family: 'Inter', sans-serif;
    font-weight: 600;
    cursor: pointer;
    transition: background .15s, border-color .15s, color .15s;
    white-space: nowrap;
    flex-shrink: 0;
    letter-spacing: .3px;
  }
  .action-btn:hover { background: rgba(168,207,255,0.22); border-color: var(--border-foc); color: #fff; }
  .action-btn:active { background: rgba(168,207,255,0.3); }

  /* Badge */
  .badge {
    font-size: 10px;
    font-family: 'JetBrains Mono', monospace;
    background: rgba(168,207,255,0.1);
    border: 1px solid rgba(168,207,255,0.2);
    color: var(--accent);
    padding: 2px 7px;
    border-radius: 99px;
    flex-shrink: 0;
  }

  /* ═══════════════ NOTIFICATION ═══════════════ */
  .notif-area {
    position: fixed;
    bottom: 18px; right: 18px;
    display: flex; flex-direction: column-reverse; gap: 8px;
    z-index: 999;
    pointer-events: none;
  }
  .notif {
    background: rgba(4,18,58,0.95);
    border: 1px solid var(--border-foc);
    border-radius: var(--radius-sm);
    padding: 12px 14px;
    width: 260px;
    backdrop-filter: blur(16px);
    animation: notifIn .25s ease both;
    pointer-events: auto;
    position: relative;
    overflow: hidden;
  }
  @keyframes notifIn { from{opacity:0;transform:translateX(20px)} to{opacity:1;transform:none} }
  .notif-bar { position: absolute; left: 0; top: 10%; bottom: 10%; width: 3px; background: var(--accent); border-radius: 0 2px 2px 0; }
  .notif-title { font-size: 12px; font-weight: 600; color: var(--txt-a); font-family:'Syne',sans-serif; }
  .notif-body  { font-size: 11px; color: var(--txt-b); margin-top: 3px; }
  .notif-progress { position:absolute; bottom:0; left:0; height:2px; background:var(--accent); border-radius:99px; animation: notifProg 3s linear both; }
  @keyframes notifProg { from{width:100%} to{width:0} }
</style>
</head>
<body>

<!-- MAIN WINDOW -->
<div class="window" id="window">

  <!-- SIDEBAR -->
  <div class="sidebar">
    <div class="sidebar-header" id="dragHandle">
      <div class="sidebar-logo">DevN.gg</div>
      <div class="sidebar-version">v4.4 · Frosted Glass</div>
    </div>

    <nav class="sidebar-nav">
      <button class="tab-btn" data-tab="main" onclick="switchTab('main',this)">
        <span class="tab-icon">⌂</span> Main
      </button>
      <button class="tab-btn active" data-tab="autofarm" onclick="switchTab('autofarm',this)">
        <span class="tab-icon">⚡</span> Auto Farm
      </button>
      <button class="tab-btn" data-tab="boss" onclick="switchTab('boss',this)">
        <span class="tab-icon">☠</span> Boss
      </button>
      <button class="tab-btn" data-tab="dungeon" onclick="switchTab('dungeon',this)">
        <span class="tab-icon">⬡</span> Dungeon
      </button>
      <button class="tab-btn" data-tab="stats" onclick="switchTab('stats',this)">
        <span class="tab-icon">↗</span> Stats
      </button>
      <button class="tab-btn" data-tab="teleport" onclick="switchTab('teleport',this)">
        <span class="tab-icon">◈</span> Teleport
      </button>
      <button class="tab-btn" data-tab="trade" onclick="switchTab('trade',this)">
        <span class="tab-icon">⇆</span> Trade
      </button>
      <button class="tab-btn" data-tab="settings" onclick="switchTab('settings',this)">
        <span class="tab-icon">⚙</span> Settings
      </button>
    </nav>

    <div class="sidebar-footer">[ K ] Toggle UI</div>
  </div>

  <!-- CONTENT -->
  <div class="content">
    <div class="content-header" id="dragHandle2">
      <div class="content-title" id="contentTitle">Auto Farm</div>
      <div class="win-controls">
        <button class="win-btn min" title="Minimise" onclick="showNotif('UI','Window minimised.')">−</button>
        <button class="win-btn close" title="Close" onclick="showNotif('UI','Window hidden. Press K to reopen.')">×</button>
      </div>
    </div>

    <div class="content-body">

      <!-- ══ AUTO FARM TAB ══ -->
      <div class="tab-panel active" id="tab-autofarm">

        <div class="row">
          <div class="row-label">Auto Equip Weapon</div>
          <label class="toggle-wrap">
            <input type="checkbox" checked onchange="onToggle(this,'autoEquip')"/>
            <span class="toggle-slider"></span>
          </label>
        </div>

        <div class="section-label">Method Farm</div>

        <div class="row">
          <div class="row-label">
            Farm Method
            <span class="sub">เลือกตาราวปที่จะฟาร์ม</span>
          </div>
          <div class="dropdown" id="dd-farmmethod">
            <div class="dropdown-btn" onclick="toggleDropdown('dd-farmmethod')">
              <span class="dd-val">TP</span>
              <span class="dropdown-arrow">▾</span>
            </div>
            <div class="dropdown-menu">
              <div class="dropdown-item selected" onclick="selectDD('dd-farmmethod','TP',this)">TP</div>
              <div class="dropdown-item" onclick="selectDD('dd-farmmethod','Walk',this)">Walk</div>
              <div class="dropdown-item" onclick="selectDD('dd-farmmethod','Fly',this)">Fly</div>
            </div>
          </div>
        </div>

        <div class="section-label">Mob Farm</div>

        <div class="row">
          <div class="row-label">
            Select Mob
          </div>
          <div class="dropdown" id="dd-mob">
            <div class="dropdown-btn" onclick="toggleDropdown('dd-mob')">
              <span class="dd-val">Quincy (Lv. 10750)</span>
              <span class="dropdown-arrow">▾</span>
            </div>
            <div class="dropdown-menu">
              <div class="dropdown-item selected" onclick="selectDD('dd-mob','Quincy (Lv. 10750)',this)">Quincy (Lv. 10750)</div>
              <div class="dropdown-item" onclick="selectDD('dd-mob','Hollow (Lv. 9800)',this)">Hollow (Lv. 9800)</div>
              <div class="dropdown-item" onclick="selectDD('dd-mob','Shinigami (Lv. 11200)',this)">Shinigami (Lv. 11200)</div>
              <div class="dropdown-item" onclick="selectDD('dd-mob','Espada (Lv. 15000)',this)">Espada (Lv. 15000)</div>
              <div class="dropdown-item" onclick="selectDD('dd-mob','Arrancar (Lv. 12400)',this)">Arrancar (Lv. 12400)</div>
            </div>
          </div>
        </div>

        <div class="row">
          <div class="row-label">Auto Farm</div>
          <label class="toggle-wrap">
            <input type="checkbox" checked onchange="onToggle(this,'autoFarm')"/>
            <span class="toggle-slider"></span>
          </label>
        </div>

        <div class="row">
          <div class="row-label">
            Auto Farm Level
            <span class="sub">ฟาร์มตามเลเวลอัตโนมัติ</span>
          </div>
          <label class="toggle-wrap">
            <input type="checkbox" onchange="onToggle(this,'autoFarmLevel')"/>
            <span class="toggle-slider"></span>
          </label>
        </div>

        <div class="row">
          <div class="row-label">
            Farm Position
            <span class="sub">ตำแหน่งฟาร์ม</span>
          </div>
          <div class="dropdown" id="dd-position">
            <div class="dropdown-btn" onclick="toggleDropdown('dd-position')">
              <span class="dd-val">Behind</span>
              <span class="dropdown-arrow">▾</span>
            </div>
            <div class="dropdown-menu">
              <div class="dropdown-item selected" onclick="selectDD('dd-position','Behind',this)">Behind</div>
              <div class="dropdown-item" onclick="selectDD('dd-position','Front',this)">Front</div>
              <div class="dropdown-item" onclick="selectDD('dd-position','Right',this)">Right</div>
              <div class="dropdown-item" onclick="selectDD('dd-position','Left',this)">Left</div>
            </div>
          </div>
        </div>

        <div class="section-label">All Mob Farm</div>

        <div class="row">
          <div class="row-label">Farm All Mobs in Area</div>
          <label class="toggle-wrap">
            <input type="checkbox" onchange="onToggle(this,'allMobFarm')"/>
            <span class="toggle-slider"></span>
          </label>
        </div>

        <div class="row">
          <div class="row-label">
            Farm Radius
          </div>
          <div class="slider-wrap">
            <input type="range" min="10" max="200" value="60" oninput="this.nextElementSibling.textContent=this.value"/>
            <span class="slider-val">60</span>
          </div>
        </div>

      </div>

      <!-- ══ MAIN TAB ══ -->
      <div class="tab-panel" id="tab-main">
        <div class="section-label">Overview</div>
        <div class="row">
          <div class="row-label">Auto Save Config</div>
          <label class="toggle-wrap">
            <input type="checkbox" checked onchange="onToggle(this,'autoSave')"/>
            <span class="toggle-slider"></span>
          </label>
        </div>
        <div class="row">
          <div class="row-label">
            Script Version
          </div>
          <span class="badge">v4.4</span>
        </div>
        <div class="row">
          <div class="row-label">Load Configuration</div>
          <button class="action-btn" onclick="showNotif('Config','Configuration loaded.')">Load</button>
        </div>
        <div class="row">
          <div class="row-label">Save Configuration</div>
          <button class="action-btn" onclick="showNotif('Config','Configuration saved.')">Save</button>
        </div>
      </div>

      <!-- ══ BOSS TAB ══ -->
      <div class="tab-panel" id="tab-boss">
        <div class="section-label">Boss Farm</div>
        <div class="row">
          <div class="row-label">Auto Boss Farm</div>
          <label class="toggle-wrap">
            <input type="checkbox" onchange="onToggle(this,'bossFarm')"/>
            <span class="toggle-slider"></span>
          </label>
        </div>
        <div class="row">
          <div class="row-label">Select Boss</div>
          <div class="dropdown" id="dd-boss">
            <div class="dropdown-btn" onclick="toggleDropdown('dd-boss')">
              <span class="dd-val">Aizen</span>
              <span class="dropdown-arrow">▾</span>
            </div>
            <div class="dropdown-menu">
              <div class="dropdown-item selected" onclick="selectDD('dd-boss','Aizen',this)">Aizen</div>
              <div class="dropdown-item" onclick="selectDD('dd-boss','Yhwach',this)">Yhwach</div>
              <div class="dropdown-item" onclick="selectDD('dd-boss','Barragan',this)">Barragan</div>
              <div class="dropdown-item" onclick="selectDD('dd-boss','Ulquiorra',this)">Ulquiorra</div>
            </div>
          </div>
        </div>
        <div class="row">
          <div class="row-label">Auto Rejoin on Death</div>
          <label class="toggle-wrap">
            <input type="checkbox" checked onchange="onToggle(this,'bossRejoin')"/>
            <span class="toggle-slider"></span>
          </label>
        </div>
      </div>

      <!-- ══ DUNGEON TAB ══ -->
      <div class="tab-panel" id="tab-dungeon">
        <div class="section-label">Dungeon</div>
        <div class="row">
          <div class="row-label">Auto Clear Dungeon</div>
          <label class="toggle-wrap">
            <input type="checkbox" onchange="onToggle(this,'autoDungeon')"/>
            <span class="toggle-slider"></span>
          </label>
        </div>
        <div class="row">
          <div class="row-label">Dungeon Floor</div>
          <div class="dropdown" id="dd-dungeon">
            <div class="dropdown-btn" onclick="toggleDropdown('dd-dungeon')">
              <span class="dd-val">Floor 10</span>
              <span class="dropdown-arrow">▾</span>
            </div>
            <div class="dropdown-menu">
              <div class="dropdown-item" onclick="selectDD('dd-dungeon','Floor 1',this)">Floor 1</div>
              <div class="dropdown-item" onclick="selectDD('dd-dungeon','Floor 5',this)">Floor 5</div>
              <div class="dropdown-item selected" onclick="selectDD('dd-dungeon','Floor 10',this)">Floor 10</div>
              <div class="dropdown-item" onclick="selectDD('dd-dungeon','Floor 20',this)">Floor 20</div>
            </div>
          </div>
        </div>
      </div>

      <!-- ══ STATS TAB ══ -->
      <div class="tab-panel" id="tab-stats">
        <div class="section-label">Auto Stats</div>
        <div class="row">
          <div class="row-label">Auto Assign Stats</div>
          <label class="toggle-wrap">
            <input type="checkbox" checked onchange="onToggle(this,'autoStats')"/>
            <span class="toggle-slider"></span>
          </label>
        </div>
        <div class="row">
          <div class="row-label">Stat Priority</div>
          <div class="dropdown" id="dd-stat">
            <div class="dropdown-btn" onclick="toggleDropdown('dd-stat')">
              <span class="dd-val">Strength</span>
              <span class="dropdown-arrow">▾</span>
            </div>
            <div class="dropdown-menu">
              <div class="dropdown-item selected" onclick="selectDD('dd-stat','Strength',this)">Strength</div>
              <div class="dropdown-item" onclick="selectDD('dd-stat','Defense',this)">Defense</div>
              <div class="dropdown-item" onclick="selectDD('dd-stat','Speed',this)">Speed</div>
              <div class="dropdown-item" onclick="selectDD('dd-stat','Spirit',this)">Spirit</div>
            </div>
          </div>
        </div>
      </div>

      <!-- ══ TELEPORT TAB ══ -->
      <div class="tab-panel" id="tab-teleport">
        <div class="section-label">Teleport</div>
        <div class="row">
          <div class="row-label">Auto Teleport to Mob</div>
          <label class="toggle-wrap">
            <input type="checkbox" onchange="onToggle(this,'autoTP')"/>
            <span class="toggle-slider"></span>
          </label>
        </div>
        <div class="row">
          <div class="row-label">Teleport Location</div>
          <div class="dropdown" id="dd-tp">
            <div class="dropdown-btn" onclick="toggleDropdown('dd-tp')">
              <span class="dd-val">Soul Society</span>
              <span class="dropdown-arrow">▾</span>
            </div>
            <div class="dropdown-menu">
              <div class="dropdown-item selected" onclick="selectDD('dd-tp','Soul Society',this)">Soul Society</div>
              <div class="dropdown-item" onclick="selectDD('dd-tp','Hueco Mundo',this)">Hueco Mundo</div>
              <div class="dropdown-item" onclick="selectDD('dd-tp','Karakura Town',this)">Karakura Town</div>
            </div>
          </div>
        </div>
        <div class="row">
          <div class="row-label">Teleport to Player</div>
          <button class="action-btn" onclick="showNotif('Teleport','Teleporting to nearest player...')">TP Now</button>
        </div>
      </div>

      <!-- ══ TRADE TAB ══ -->
      <div class="tab-panel" id="tab-trade">
        <div class="section-label">Trade</div>
        <div class="row">
          <div class="row-label">Auto Accept Trade</div>
          <label class="toggle-wrap">
            <input type="checkbox" onchange="onToggle(this,'autoTrade')"/>
            <span class="toggle-slider"></span>
          </label>
        </div>
        <div class="row">
          <div class="row-label">Trade Mode</div>
          <div class="dropdown" id="dd-trade">
            <div class="dropdown-btn" onclick="toggleDropdown('dd-trade')">
              <span class="dd-val">Safe</span>
              <span class="dropdown-arrow">▾</span>
            </div>
            <div class="dropdown-menu">
              <div class="dropdown-item selected" onclick="selectDD('dd-trade','Safe',this)">Safe</div>
              <div class="dropdown-item" onclick="selectDD('dd-trade','Aggressive',this)">Aggressive</div>
            </div>
          </div>
        </div>
      </div>

      <!-- ══ SETTINGS TAB ══ -->
      <div class="tab-panel" id="tab-settings">
        <div class="section-label">UI Settings</div>
        <div class="row">
          <div class="row-label">
            UI Scale
          </div>
          <div class="slider-wrap">
            <input type="range" min="80" max="150" value="100" oninput="this.nextElementSibling.textContent=this.value+'%'"/>
            <span class="slider-val">100%</span>
          </div>
        </div>
        <div class="row">
          <div class="row-label">Show Notifications</div>
          <label class="toggle-wrap">
            <input type="checkbox" checked onchange="onToggle(this,'notifs')"/>
            <span class="toggle-slider"></span>
          </label>
        </div>
        <div class="section-label">Keybinds</div>
        <div class="row">
          <div class="row-label">Toggle UI Key</div>
          <span class="badge">K</span>
        </div>
        <div class="section-label">Danger Zone</div>
        <div class="row">
          <div class="row-label">Reset All Settings</div>
          <button class="action-btn" onclick="showNotif('Settings','All settings reset to default.')">Reset</button>
        </div>
      </div>

    </div><!-- end content-body -->
  </div><!-- end content -->
</div><!-- end window -->

<!-- NOTIFICATIONS -->
<div class="notif-area" id="notifArea"></div>

<script>
  /* ══ TAB SWITCHING ══ */
  const tabTitles = {
    main:'Main', autofarm:'Auto Farm', boss:'Boss',
    dungeon:'Dungeon', stats:'Stats', teleport:'Teleport',
    trade:'Trade', settings:'Settings'
  };
  function switchTab(id, btn) {
    document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
    document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
    document.getElementById('tab-' + id).classList.add('active');
    btn.classList.add('active');
    document.getElementById('contentTitle').textContent = tabTitles[id] || id;
    closeAllDropdowns();
  }

  /* ══ DROPDOWN ══ */
  function toggleDropdown(id) {
    const dd = document.getElementById(id);
    const btn = dd.querySelector('.dropdown-btn');
    const menu = dd.querySelector('.dropdown-menu');
    const isOpen = menu.classList.contains('open');
    closeAllDropdowns();
    if (!isOpen) {
      btn.classList.add('open');
      menu.classList.add('open');
    }
  }
  function selectDD(ddId, value, el) {
    const dd = document.getElementById(ddId);
    dd.querySelector('.dd-val').textContent = value;
    dd.querySelectorAll('.dropdown-item').forEach(i => i.classList.remove('selected'));
    el.classList.add('selected');
    closeAllDropdowns();
    showNotif('Setting', ddId.replace('dd-','').replace('-',' ') + ' → ' + value);
  }
  function closeAllDropdowns() {
    document.querySelectorAll('.dropdown-btn.open').forEach(b => b.classList.remove('open'));
    document.querySelectorAll('.dropdown-menu.open').forEach(m => m.classList.remove('open'));
  }
  document.addEventListener('click', e => {
    if (!e.target.closest('.dropdown')) closeAllDropdowns();
  });

  /* ══ TOGGLE ══ */
  function onToggle(el, flag) {
    const state = el.checked ? 'ON' : 'OFF';
    showNotif(flag, flag + ' turned ' + state);
  }

  /* ══ NOTIFICATIONS ══ */
  let notifCount = 0;
  function showNotif(title, body) {
    if (notifCount >= 4) return;
    notifCount++;
    const area = document.getElementById('notifArea');
    const n = document.createElement('div');
    n.className = 'notif';
    n.innerHTML = `
      <div class="notif-bar"></div>
      <div class="notif-title">${title}</div>
      <div class="notif-body">${body}</div>
      <div class="notif-progress"></div>
    `;
    area.appendChild(n);
    setTimeout(() => {
      n.style.transition = 'opacity .25s, transform .25s';
      n.style.opacity = '0';
      n.style.transform = 'translateX(20px)';
      setTimeout(() => { n.remove(); notifCount--; }, 280);
    }, 3000);
  }

  /* ══ DRAG ══ */
  let dragging = false, ox = 0, oy = 0;
  const win = document.getElementById('window');
  win.style.position = 'absolute';
  win.style.left = '50%'; win.style.top = '50%';
  win.style.transform = 'translate(-50%,-50%)';

  function startDrag(e) {
    dragging = true;
    const r = win.getBoundingClientRect();
    ox = (e.touches ? e.touches[0].clientX : e.clientX) - r.left;
    oy = (e.touches ? e.touches[0].clientY : e.clientY) - r.top;
    win.style.transform = 'none';
    win.style.left = r.left + 'px';
    win.style.top  = r.top  + 'px';
    e.preventDefault();
  }
  document.getElementById('dragHandle').addEventListener('mousedown', startDrag);
  document.getElementById('dragHandle2').addEventListener('mousedown', startDrag);
  document.getElementById('dragHandle').addEventListener('touchstart', startDrag, {passive:false});
  document.getElementById('dragHandle2').addEventListener('touchstart', startDrag, {passive:false});

  document.addEventListener('mousemove', e => {
    if (!dragging) return;
    win.style.left = (e.clientX - ox) + 'px';
    win.style.top  = (e.clientY - oy) + 'px';
  });
  document.addEventListener('mouseup', () => dragging = false);
  document.addEventListener('touchmove', e => {
    if (!dragging) return;
    win.style.left = (e.touches[0].clientX - ox) + 'px';
    win.style.top  = (e.touches[0].clientY - oy) + 'px';
  });
  document.addEventListener('touchend', () => dragging = false);

  /* welcome notif */
  setTimeout(() => showNotif('DevN.gg', 'Script loaded. Press K to toggle.'), 400);
</script>
</body>
</html>
