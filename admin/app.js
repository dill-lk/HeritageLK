/**
 * HeritageLK Admin — Standalone Supabase Damage Reports App
 */

// ─── CONFIGURATION & INITIAL STATE ──────────────────────────────────────────
const DEFAULT_SUPABASE_URL = 'https://emeqmaqmmaohkeecyvjq.supabase.co';
const DEFAULT_SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVtZXFtYXFtbWFvaGtlZWN5dmpxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg5ODk3MDUsImV4cCI6MjA5NDU2NTcwNX0.-SmCu_5kd_cDs2NYbzNN33hlxXbyRln4Cd5cgQJ3lGI';
const STORAGE_KEY_URL = 'heritagelk_admin_supabase_url';
const STORAGE_KEY_ANON = 'heritagelk_admin_supabase_key';
const STORAGE_KEY_REPORTS = 'heritagelk_admin_offline_reports_v1';

let supabaseClient = null;
let currentReports = [];
let filteredReports = [];
let activeStatusFilter = 'all';
let activeSeverityFilter = 'all';
let activeView = 'table'; // 'table' or 'grid'
let selectedReportId = null;
let statusChartInstance = null;
let typeChartInstance = null;

// ─── SEED DATA FOR OFFLINE / DEMO MODE ──────────────────────────────────────
const MOCK_REPORTS = [
  {
    id: 'DR-10928',
    location: 'Sigiriya Lion Paw Terrace, Central Province',
    damage_type: 'Structural Crack',
    details: 'Deep vertical fissure discovered near the left lion claw brick foundation after heavy monsoon rain. Requires urgent masonry assessment by Central Cultural Fund engineers.',
    status: 'pending',
    created_at: '2026-07-28T14:32:00Z',
    photos: ['https://images.unsplash.com/photo-1546708973-b339540b5162?auto=format&fit=crop&w=600&q=80'],
    notes: 'Awaiting site visit from Dambulla regional archaeological officer.'
  },
  {
    id: 'DR-10927',
    location: 'Galle Dutch Fort Sea Wall (Flag Rock), Southern Province',
    damage_type: 'Weathering & Erosion',
    details: 'High tidal surge wave action has loosened coral limestone blocks along the south-western rampart foundation. Minor seawater seepage observed.',
    status: 'in_review',
    created_at: '2026-07-26T09:15:00Z',
    photos: ['https://images.unsplash.com/photo-1586861635167-e5223aadc9fe?auto=format&fit=crop&w=600&q=80'],
    notes: 'Coastal Conservation Department notified. Inspection team scheduled.'
  },
  {
    id: 'DR-10926',
    location: 'Dambulla Cave Temple (Cave #2 Maharaja Lena), Matale',
    damage_type: 'Water Leakage',
    details: 'Moisture dampening detected on 1st-century ceiling mural depicting King Devanampiyatissa. Slight pigment discoloration on northern corner.',
    status: 'pending',
    created_at: '2026-07-25T11:45:00Z',
    photos: ['https://images.unsplash.com/photo-1609831143883-9b984578b9b8?auto=format&fit=crop&w=600&q=80'],
    notes: ''
  },
  {
    id: 'DR-10925',
    location: 'Polonnaruwa Vatadage Ancient Stairway, Polonnaruwa',
    damage_type: 'Vegetation Overgrowth',
    details: 'Heavy banyan tree root penetration under the granite moonstone step base. Roots are lifting ancient carved guardstones.',
    status: 'resolved',
    created_at: '2026-07-20T16:20:00Z',
    photos: ['https://images.unsplash.com/photo-1580674684081-7617fbf3d745?auto=format&fit=crop&w=600&q=80'],
    notes: 'Roots carefully trimmed by CCF conservationists on Jul 23. Guardstone stabilized.'
  },
  {
    id: 'DR-10924',
    location: 'Anuradhapura Ruwanwelisaya Elephant Wall, North Central',
    damage_type: 'Vandalism',
    details: 'Minor paint graffiti scrawled on outer white stucco wall near western gate entrance.',
    status: 'resolved',
    created_at: '2026-07-18T08:10:00Z',
    photos: ['https://images.unsplash.com/photo-1625736338592-f72671607590?auto=format&fit=crop&w=600&q=80'],
    notes: 'Wall repainted with traditional lime wash. Temple guardians notified.'
  },
  {
    id: 'DR-10923',
    location: 'Yapahuwa Rock Fortress Ornamental Stairway',
    damage_type: 'Structural Crack',
    details: 'Upper carved lion balustrade granite slab showing 2cm shift due to soil erosion.',
    status: 'rejected',
    created_at: '2026-07-12T13:00:00Z',
    photos: [],
    notes: 'Duplicate report of DR-10880 already under active restoration.'
  }
];

// ─── INITIALIZATION ─────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  initSupabase();
  bindEvents();
  loadReports();
});

function getActiveUrl() {
  return localStorage.getItem(STORAGE_KEY_URL) || DEFAULT_SUPABASE_URL;
}

function getActiveKey() {
  return localStorage.getItem(STORAGE_KEY_ANON) || DEFAULT_SUPABASE_KEY;
}

// Initialize Supabase Client
function initSupabase() {
  const url = getActiveUrl();
  const key = getActiveKey();

  const badge = document.getElementById('connectionBadge');
  const text = document.getElementById('connectionText');

  if (window.supabase && url && key) {
    try {
      supabaseClient = window.supabase.createClient(url, key);
      badge.className = 'connection-status connected';
      text.textContent = 'Supabase Ready';
    } catch (e) {
      console.warn('Supabase init failed:', e);
      supabaseClient = null;
      badge.className = 'connection-status offline';
      text.textContent = 'Demo Mode (Offline)';
    }
  } else {
    supabaseClient = null;
    badge.className = 'connection-status offline';
    text.textContent = 'Demo Mode (Offline)';
  }
}

// ─── DATA FETCHING & STORAGE ────────────────────────────────────────────────
async function loadReports() {
  showLoading(true);

  const url = getActiveUrl();
  const key = getActiveKey();
  const badge = document.getElementById('connectionBadge');
  const text = document.getElementById('connectionText');

  let fetchedData = null;

  // 1. Try JS Client first
  if (supabaseClient) {
    try {
      const { data, error } = await supabaseClient
        .from('damage_reports')
        .select('*')
        .order('created_at', { ascending: false });

      if (!error && Array.isArray(data)) {
        fetchedData = data;
        console.log('✅ Fetched damage_reports via Supabase JS Client:', data);
      } else {
        console.warn('JS Client fetch error:', error);
      }
    } catch (err) {
      console.warn('JS Client fetch exception:', err);
    }
  }

  // 2. Fallback to direct HTTP REST API fetch if JS client failed or wasn't loaded
  if (!fetchedData && url && key) {
    try {
      const endpoint = `${url.replace(/\/$/, '')}/rest/v1/damage_reports?select=*&order=created_at.desc`;
      const res = await fetch(endpoint, {
        headers: {
          'apikey': key,
          'Authorization': `Bearer ${key}`,
          'Content-Type': 'application/json'
        }
      });
      if (res.ok) {
        fetchedData = await res.json();
        console.log('✅ Fetched damage_reports via Supabase REST API:', fetchedData);
      } else {
        console.warn(`REST API error HTTP ${res.status}:`, await res.text());
      }
    } catch (e) {
      console.warn('REST API fetch exception:', e);
    }
  }

  if (fetchedData && Array.isArray(fetchedData)) {
    badge.className = 'connection-status connected';
    text.textContent = `Supabase Live (${fetchedData.length} records)`;

    if (fetchedData.length > 0) {
      currentReports = fetchedData.map(normalizeReport);
    } else {
      // Table exists but currently has 0 rows — keep empty or prompt user
      currentReports = [];
      console.log('Supabase table damage_reports returned 0 rows.');
    }
  } else {
    // Offline or connection failure fallback
    badge.className = 'connection-status offline';
    text.textContent = 'Offline Demo Mode';
    currentReports = getLocalReports();
  }

  showLoading(false);
  applyFilters();
}

function getLocalReports() {
  const saved = localStorage.getItem(STORAGE_KEY_REPORTS);
  if (saved) {
    try { return JSON.parse(saved); } catch (_) {}
  }
  localStorage.setItem(STORAGE_KEY_REPORTS, JSON.stringify(MOCK_REPORTS));
  return MOCK_REPORTS;
}

function saveLocalReports() {
  localStorage.setItem(STORAGE_KEY_REPORTS, JSON.stringify(currentReports));
}

function normalizeReport(raw) {
  let photosList = [];
  if (raw.photo_url && String(raw.photo_url).trim().length > 0) {
    photosList = [raw.photo_url];
  } else if (Array.isArray(raw.photos) && raw.photos.length > 0) {
    photosList = raw.photos;
  }

  return {
    id: raw.id || `DR-${Math.floor(10000 + Math.random() * 90000)}`,
    location: raw.location || 'Unknown Heritage Site',
    damage_type: raw.damage_type || 'General Damage',
    details: raw.details || 'No description provided.',
    status: raw.status || 'pending',
    created_at: raw.created_at || new Date().toISOString(),
    photos: photosList,
    photo_url: raw.photo_url || (photosList.length > 0 ? photosList[0] : null),
    notes: raw.notes || ''
  };
}

// ─── FILTERING & RENDERING ──────────────────────────────────────────────────
function applyFilters() {
  const query = document.getElementById('searchInput').value.toLowerCase().trim();

  filteredReports = currentReports.filter(r => {
    // Status Filter
    if (activeStatusFilter !== 'all' && r.status !== activeStatusFilter) return false;
    
    // Severity/Type Filter
    if (activeSeverityFilter !== 'all' && r.damage_type !== activeSeverityFilter) return false;

    // Search Query
    if (query) {
      const matchLoc = r.location.toLowerCase().includes(query);
      const matchType = r.damage_type.toLowerCase().includes(query);
      const matchDet = r.details.toLowerCase().includes(query);
      const matchId = r.id.toLowerCase().includes(query);
      return matchLoc || matchType || matchDet || matchId;
    }

    return true;
  });

  updateStats();
  renderReports();
  updateCharts();
}

function updateStats() {
  const total = currentReports.length;
  const pending = currentReports.filter(r => r.status === 'pending').length;
  const review = currentReports.filter(r => r.status === 'in_review').length;
  const resolved = currentReports.filter(r => r.status === 'resolved').length;

  document.getElementById('statTotal').textContent = total;
  document.getElementById('statPending').textContent = pending;
  document.getElementById('statReview').textContent = review;
  document.getElementById('statResolved').textContent = resolved;
}

function renderReports() {
  const tbody = document.getElementById('reportsTableBody');
  const grid = document.getElementById('gridView');
  const empty = document.getElementById('stateContainer');

  if (filteredReports.length === 0) {
    document.getElementById('tableView').classList.add('hidden');
    grid.classList.add('hidden');
    empty.classList.remove('hidden');
    document.getElementById('stateTitle').textContent = 'No Damage Reports Found';
    document.getElementById('stateDesc').textContent = 'Try adjusting your search query or filter selection.';
    return;
  }

  empty.classList.add('hidden');

  if (activeView === 'table') {
    document.getElementById('tableView').classList.remove('hidden');
    grid.classList.add('hidden');
    tbody.innerHTML = filteredReports.map(r => `
      <tr>
        <td>
          <div class="site-title">${escapeHtml(r.location)}</div>
          <div class="site-sub">ID: ${r.id}</div>
        </td>
        <td>
          <span class="damage-tag"><i class="fa-solid fa-triangle-exclamation"></i> ${escapeHtml(r.damage_type)}</span>
        </td>
        <td>
          <div class="details-preview" style="max-width:280px; text-overflow:ellipsis; overflow:hidden; white-space:nowrap;">
            ${escapeHtml(r.details)}
          </div>
        </td>
        <td>${formatDate(r.created_at)}</td>
        <td>
          <span class="badge badge-${r.status}">${formatStatus(r.status)}</span>
        </td>
        <td>
          ${r.photos && r.photos.length > 0 
            ? `<img src="${r.photos[0]}" class="photo-thumb" alt="Damage photo" onerror="this.src='https://images.unsplash.com/photo-1546708973-b339540b5162?w=100'">`
            : `<div class="photo-placeholder"><i class="fa-solid fa-camera"></i></div>`}
        </td>
        <td class="text-right">
          <button class="btn btn-secondary btn-sm" onclick="openDetailModal('${r.id}')">
            <i class="fa-solid fa-eye"></i> Manage
          </button>
        </td>
      </tr>
    `).join('');
  } else {
    document.getElementById('tableView').classList.add('hidden');
    grid.classList.remove('hidden');
    grid.innerHTML = filteredReports.map(r => `
      <div class="report-card">
        <div class="report-card-header">
          <div>
            <span class="badge badge-${r.status}">${formatStatus(r.status)}</span>
            <h3 style="margin-top:8px; font-size:16px;">${escapeHtml(r.location)}</h3>
          </div>
          <span class="damage-tag"><i class="fa-solid fa-triangle-exclamation"></i> ${escapeHtml(r.damage_type)}</span>
        </div>

        ${r.photos && r.photos.length > 0 
          ? `<img src="${r.photos[0]}" style="width:100%; height:140px; object-fit:cover; border-radius:12px;" onerror="this.style.display='none'">`
          : ''}

        <div class="report-card-body">
          <p style="margin-bottom:8px;">${escapeHtml(r.details)}</p>
          <small style="color:var(--text-muted);"><i class="fa-solid fa-calendar"></i> ${formatDate(r.created_at)}</small>
        </div>

        <button class="btn btn-secondary" onclick="openDetailModal('${r.id}')" style="width:100%;">
          <i class="fa-solid fa-sliders"></i> Manage Report
        </button>
      </div>
    `).join('');
  }
}

// ─── CHARTS LOGIC ───────────────────────────────────────────────────────────
function updateCharts() {
  const drawer = document.getElementById('chartsDrawer');
  if (drawer.classList.contains('hidden')) return;

  const statusCounts = { pending: 0, in_review: 0, resolved: 0, rejected: 0 };
  const typeCounts = {};

  currentReports.forEach(r => {
    if (statusCounts[r.status] !== undefined) statusCounts[r.status]++;
    typeCounts[r.damage_type] = (typeCounts[r.damage_type] || 0) + 1;
  });

  // Doughnut Chart
  const ctxStatus = document.getElementById('statusChart').getContext('2d');
  if (statusChartInstance) statusChartInstance.destroy();

  statusChartInstance = new Chart(ctxStatus, {
    type: 'doughnut',
    data: {
      labels: ['Pending', 'In Review', 'Resolved', 'Rejected'],
      datasets: [{
        data: [statusCounts.pending, statusCounts.in_review, statusCounts.resolved, statusCounts.rejected],
        backgroundColor: ['#E9C46A', '#457B9D', '#2A9D8F', '#E76F51'],
        borderWidth: 0
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { position: 'right', labels: { color: '#FEFAE0', font: { family: 'Inter' } } }
      }
    }
  });

  // Bar Chart
  const ctxType = document.getElementById('typeChart').getContext('2d');
  if (typeChartInstance) typeChartInstance.destroy();

  typeChartInstance = new Chart(ctxType, {
    type: 'bar',
    data: {
      labels: Object.keys(typeCounts),
      datasets: [{
        label: 'Reports',
        data: Object.values(typeCounts),
        backgroundColor: '#F4A261',
        borderRadius: 8
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: { legend: { display: false } },
      scales: {
        x: { ticks: { color: '#C5BEAE' }, grid: { display: false } },
        y: { ticks: { color: '#C5BEAE' }, grid: { color: 'rgba(255,255,255,0.05)' } }
      }
    }
  });
}

// ─── MODALS & ACTIONS ───────────────────────────────────────────────────────
window.openDetailModal = function(id) {
  const report = currentReports.find(r => r.id === id);
  if (!report) return;

  selectedReportId = id;

  document.getElementById('modalSiteTitle').textContent = report.location;
  document.getElementById('modalDamageType').textContent = report.damage_type;
  document.getElementById('modalReportMeta').textContent = `#${report.id} • ${formatDate(report.created_at)}`;
  document.getElementById('modalLocationText').textContent = report.location;
  document.getElementById('modalMapLink').href = `https://www.google.com/maps/search/?api=1&query=${encodeURIComponent(report.location)}`;
  document.getElementById('modalDetailsText').textContent = report.details;

  // Status Badge
  const badge = document.getElementById('modalStatusBadge');
  badge.className = `badge badge-${report.status}`;
  badge.textContent = formatStatus(report.status);

  // Photos
  const gallery = document.getElementById('modalPhotosGallery');
  if (report.photos && report.photos.length > 0) {
    gallery.innerHTML = report.photos.map(p => `
      <a href="${p}" target="_blank">
        <img src="${p}" class="gallery-img" alt="Evidence" onerror="this.style.display='none'">
      </a>
    `).join('');
  } else {
    gallery.innerHTML = '<span class="text-muted">No photo attached.</span>';
  }

  // Update inputs
  document.getElementById('updateStatusSelect').value = report.status;
  document.getElementById('updateNotesInput').value = report.notes || '';

  document.getElementById('detailModal').classList.remove('hidden');
};

async function saveStatusChanges() {
  if (!selectedReportId) return;

  const newStatus = document.getElementById('updateStatusSelect').value;
  const newNotes = document.getElementById('updateNotesInput').value.trim();

  // Optimistic UI update
  const reportIndex = currentReports.findIndex(r => r.id === selectedReportId);
  if (reportIndex !== -1) {
    currentReports[reportIndex].status = newStatus;
    currentReports[reportIndex].notes = newNotes;
  }

  if (supabaseClient) {
    try {
      await supabaseClient
        .from('damage_reports')
        .update({ status: newStatus, notes: newNotes })
        .eq('id', selectedReportId);
    } catch (e) {
      console.warn('Supabase status update failed:', e);
    }
  }

  saveLocalReports();
  document.getElementById('detailModal').classList.add('hidden');
  applyFilters();
}

async function deleteReport() {
  if (!selectedReportId) return;
  if (!confirm('Are you sure you want to delete this damage report? This action cannot be undone.')) return;

  currentReports = currentReports.filter(r => r.id !== selectedReportId);

  if (supabaseClient) {
    try {
      await supabaseClient
        .from('damage_reports')
        .delete()
        .eq('id', selectedReportId);
    } catch (e) {
      console.warn('Supabase delete failed:', e);
    }
  }

  saveLocalReports();
  document.getElementById('detailModal').classList.add('hidden');
  applyFilters();
}

async function createNewReport(e) {
  e.preventDefault();

  const location = document.getElementById('newLocation').value.trim();
  const damage_type = document.getElementById('newDamageType').value;
  const status = document.getElementById('newInitialStatus').value;
  const details = document.getElementById('newDetails').value.trim();
  const photoUrl = document.getElementById('newPhotoUrl').value.trim();

  const newReport = {
    id: `DR-${Math.floor(10000 + Math.random() * 90000)}`,
    location,
    damage_type,
    status,
    details,
    created_at: new Date().toISOString(),
    photos: photoUrl ? [photoUrl] : [],
    notes: 'Manually logged by CCF Admin'
  };

  currentReports.unshift(newReport);

  if (supabaseClient) {
    try {
      await supabaseClient.from('damage_reports').insert([{
        location,
        damage_type,
        status,
        details,
        photo_url: photoUrl
      }]);
    } catch (err) {
      console.warn('Supabase insert error:', err);
    }
  }

  saveLocalReports();
  document.getElementById('createReportForm').reset();
  document.getElementById('createModal').classList.add('hidden');
  applyFilters();
}

// ─── EXPORTING ──────────────────────────────────────────────────────────────
function exportCSV() {
  const headers = ['ID', 'Location', 'Damage Type', 'Status', 'Date Reported', 'Details', 'Notes'];
  const rows = filteredReports.map(r => [
    `"${r.id}"`,
    `"${r.location.replace(/"/g, '""')}"`,
    `"${r.damage_type}"`,
    `"${r.status}"`,
    `"${r.created_at}"`,
    `"${r.details.replace(/"/g, '""')}"`,
    `"${(r.notes || '').replace(/"/g, '""')}"`
  ]);

  const csvContent = 'data:text/csv;charset=utf-8,' + [headers.join(','), ...rows.map(e => e.join(','))].join('\n');
  const encodedUri = encodeURI(csvContent);
  const link = document.createElement('a');
  link.setAttribute('href', encodedUri);
  link.setAttribute('download', `heritagelk_damage_reports_${new Date().toISOString().slice(0,10)}.csv`);
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}

function exportJSON() {
  const jsonContent = 'data:text/json;charset=utf-8,' + encodeURIComponent(JSON.stringify(filteredReports, null, 2));
  const link = document.createElement('a');
  link.setAttribute('href', jsonContent);
  link.setAttribute('download', `heritagelk_damage_reports_${new Date().toISOString().slice(0,10)}.json`);
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
}

// ─── EVENT BINDINGS ─────────────────────────────────────────────────────────
function bindEvents() {
  // Search & Filter
  document.getElementById('searchInput').addEventListener('input', (e) => {
    document.getElementById('btnClearSearch').classList.toggle('hidden', !e.target.value);
    applyFilters();
  });

  document.getElementById('btnClearSearch').addEventListener('click', () => {
    document.getElementById('searchInput').value = '';
    document.getElementById('btnClearSearch').classList.add('hidden');
    applyFilters();
  });

  // Status Chip Buttons
  document.querySelectorAll('.filter-chips .chip').forEach(btn => {
    btn.addEventListener('click', (e) => {
      document.querySelectorAll('.filter-chips .chip').forEach(c => c.classList.remove('active'));
      e.target.classList.add('active');
      activeStatusFilter = e.target.dataset.status;
      applyFilters();
    });
  });

  // Severity Select
  document.getElementById('severitySelect').addEventListener('change', (e) => {
    activeSeverityFilter = e.target.value;
    applyFilters();
  });

  // Stat Card Quick Filter
  document.querySelectorAll('.stat-card').forEach(card => {
    card.addEventListener('click', () => {
      const filter = card.dataset.filter;
      activeStatusFilter = filter;
      document.querySelectorAll('.filter-chips .chip').forEach(c => {
        c.classList.toggle('active', c.dataset.status === filter);
      });
      applyFilters();
    });
  });

  // View Switcher
  document.getElementById('btnViewTable').addEventListener('click', () => {
    activeView = 'table';
    document.getElementById('btnViewTable').classList.add('active');
    document.getElementById('btnViewGrid').classList.remove('active');
    renderReports();
  });

  document.getElementById('btnViewGrid').addEventListener('click', () => {
    activeView = 'grid';
    document.getElementById('btnViewGrid').classList.add('active');
    document.getElementById('btnViewTable').classList.remove('active');
    renderReports();
  });

  // Charts Drawer Toggle
  document.getElementById('btnToggleCharts').addEventListener('click', () => {
    const drawer = document.getElementById('chartsDrawer');
    drawer.classList.toggle('hidden');
    updateCharts();
  });

  // Actions
  document.getElementById('btnRefresh').addEventListener('click', loadReports);
  document.getElementById('btnExportCSV').addEventListener('click', exportCSV);
  document.getElementById('btnExportJSON').addEventListener('click', exportJSON);

  // Detail Modal Actions
  document.getElementById('btnCloseDetail').addEventListener('click', () => document.getElementById('detailModal').classList.add('hidden'));
  document.getElementById('btnCancelDetail').addEventListener('click', () => document.getElementById('detailModal').classList.add('hidden'));
  document.getElementById('btnSaveStatus').addEventListener('click', saveStatusChanges);
  document.getElementById('btnDeleteReport').addEventListener('click', deleteReport);

  // Create Modal Actions
  document.getElementById('btnNewReport').addEventListener('click', () => document.getElementById('createModal').classList.remove('hidden'));
  document.getElementById('btnCloseCreate').addEventListener('click', () => document.getElementById('createModal').classList.add('hidden'));
  document.getElementById('btnCancelCreate').addEventListener('click', () => document.getElementById('createModal').classList.add('hidden'));
  document.getElementById('createReportForm').addEventListener('submit', createNewReport);
  document.getElementById('btnSubmitCreate').addEventListener('click', (e) => {
    const form = document.getElementById('createReportForm');
    if (form.checkValidity()) createNewReport(e);
    else form.reportValidity();
  });

  // Config Modal Actions
  document.getElementById('btnConfig').addEventListener('click', () => {
    document.getElementById('cfgSupabaseUrl').value = localStorage.getItem(STORAGE_KEY_URL) || DEFAULT_SUPABASE_URL;
    document.getElementById('cfgSupabaseKey').value = localStorage.getItem(STORAGE_KEY_ANON) || '';
    document.getElementById('configModal').classList.remove('hidden');
  });

  document.getElementById('btnCloseConfig').addEventListener('click', () => document.getElementById('configModal').classList.add('hidden'));
  document.getElementById('btnSaveConfig').addEventListener('click', () => {
    const url = document.getElementById('cfgSupabaseUrl').value.trim();
    const key = document.getElementById('cfgSupabaseKey').value.trim();

    localStorage.setItem(STORAGE_KEY_URL, url);
    localStorage.setItem(STORAGE_KEY_ANON, key);
    initSupabase();
    document.getElementById('configModal').classList.add('hidden');
    loadReports();
  });

  document.getElementById('btnResetConfig').addEventListener('click', () => {
    localStorage.removeItem(STORAGE_KEY_URL);
    localStorage.removeItem(STORAGE_KEY_ANON);
    initSupabase();
    document.getElementById('configModal').classList.add('hidden');
    loadReports();
  });
}

// ─── HELPERS ────────────────────────────────────────────────────────────────
function showLoading(show) {
  const container = document.getElementById('stateContainer');
  if (show) {
    container.classList.remove('hidden');
    document.getElementById('stateIcon').innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i>';
    document.getElementById('stateTitle').textContent = 'Loading Damage Reports...';
    document.getElementById('stateDesc').textContent = 'Querying Supabase database.';
  }
}

function formatDate(isoStr) {
  if (!isoStr) return 'N/A';
  try {
    const d = new Date(isoStr);
    return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
  } catch (_) {
    return isoStr;
  }
}

function formatStatus(status) {
  switch (status) {
    case 'pending': return 'Pending';
    case 'in_review': return 'In Review';
    case 'resolved': return 'Resolved';
    case 'rejected': return 'Rejected';
    default: return status;
  }
}

function escapeHtml(str) {
  if (!str) return '';
  return String(str)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}
