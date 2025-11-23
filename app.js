// ===========================
// Application State
// ===========================
const state = {
    currentScreen: 'home',
    booking: {
        staffId: null,
        staffName: null,
        serviceName: null,
        servicePrice: null,
        date: null,
        time: null
    },
    appointments: [],
    user: {
        name: 'עומר',
        phone: '050-1234567',
        email: 'omer@example.com'
    }
};

// Staff data
const staffMembers = [
    { id: 1, name: 'LIAM', image: 'barber1.png' },
    { id: 2, name: 'ירון', image: 'barber2.png' },
    { id: 3, name: 'אמיר', image: 'barber3.png' },
    { id: 4, name: 'עמית', image: 'barber4.png' },
    { id: 5, name: 'קווין', image: 'barber5.png' }
];

// ===========================
// Navigation Functions
// ===========================
function navigateTo(screenName) {
    // Remove active class from all screens
    document.querySelectorAll('.screen').forEach(screen => {
        screen.classList.remove('active');
    });

    // Remove active class from all nav items
    document.querySelectorAll('.nav-item').forEach(item => {
        item.classList.remove('active');
    });

    // Add active class to target screen
    const screenMap = {
        'home': 'homeScreen',
        'appointments': 'appointmentsScreen',
        'profile': 'profileScreen'
    };

    const targetScreen = document.getElementById(screenMap[screenName]);
    if (targetScreen) {
        targetScreen.classList.add('active');
        state.currentScreen = screenName;
        
        // Update active nav item
        updateActiveNav(screenName);

        // Load appointments if navigating to appointments screen
        if (screenName === 'appointments') {
            loadAppointments();
        }
    }
}

function updateActiveNav(screenName) {
    const navItems = document.querySelectorAll('.nav-item');
    navItems.forEach((item, index) => {
        const itemScreens = ['profile', 'appointments', 'home', 'booking', 'home'];
        if (itemScreens[index] === screenName) {
            item.classList.add('active');
        }
    });
}

function goBack() {
    const screenFlow = {
        'selectStaffScreen': 'homeScreen',
        'selectServiceScreen': 'selectStaffScreen',
        'selectDateScreen': 'selectServiceScreen',
        'selectTimeScreen': 'selectDateScreen'
    };

    const currentScreenElement = document.querySelector('.screen.active');
    const currentScreenId = currentScreenElement.id;
    const previousScreenId = screenFlow[currentScreenId];

    if (previousScreenId) {
        currentScreenElement.classList.remove('active');
        document.getElementById(previousScreenId).classList.add('active');
    }
}

function showScreen(screenId) {
    document.querySelectorAll('.screen').forEach(screen => {
        screen.classList.remove('active');
    });
    document.getElementById(screenId).classList.add('active');
}

// ===========================
// Booking Flow Functions
// ===========================
function startBooking() {
    showScreen('selectStaffScreen');
    // Reset booking state
    state.booking = {
        staffId: null,
        staffName: null,
        serviceName: null,
        servicePrice: null,
        date: null,
        time: null
    };
}

function selectStaffFromHome(staffId) {
    const staff = staffMembers.find(s => s.id === staffId);
    if (staff) {
        selectStaff(staff.id, staff.name);
    }
}

function selectStaff(staffId, staffName) {
    state.booking.staffId = staffId;
    state.booking.staffName = staffName;
    
    // Update subtitle in service screen
    const subtitle = document.querySelector('#selectServiceScreen .screen-subtitle');
    if (subtitle) {
        subtitle.textContent = `בחרת את ${staffName} ל`;
    }
    
    showScreen('selectServiceScreen');
}

function selectService(serviceName, price) {
    state.booking.serviceName = serviceName;
    state.booking.servicePrice = price;
    
    // Update subtitle in date screen
    const subtitle = document.querySelector('#selectDateScreen .screen-subtitle');
    if (subtitle) {
        subtitle.textContent = `בחרת את ${state.booking.staffName} ל${serviceName} ב`;
    }
    
    showScreen('selectDateScreen');
}

function selectDate(date) {
    state.booking.date = date;
    showScreen('selectTimeScreen');
}

function selectTime(time) {
    state.booking.time = time;
    
    // Create appointment
    const appointment = {
        id: Date.now(),
        staffId: state.booking.staffId,
        staffName: state.booking.staffName,
        serviceName: state.booking.serviceName,
        servicePrice: state.booking.servicePrice,
        date: state.booking.date,
        time: state.booking.time,
        status: 'confirmed',
        createdAt: new Date().toISOString()
    };
    
    // Add to appointments
    state.appointments.push(appointment);
    saveAppointments();
    
    // Show confirmation
    alert(`✅ התור נקבע בהצלחה!\n\nאיש צוות: ${appointment.staffName}\nטיפול: ${appointment.serviceName}\nתאריך: ${appointment.date}\nשעה: ${appointment.time}\nמחיר: ₪${appointment.servicePrice}`);
    
    // Navigate to appointments screen
    navigateTo('appointments');
}

// ===========================
// Waitlist Functions
// ===========================
function joinWaitlist() {
    const waitlistEntry = {
        id: Date.now(),
        staffName: state.booking.staffName,
        serviceName: state.booking.serviceName,
        createdAt: new Date().toISOString(),
        status: 'waitlist'
    };
    
    alert(`✓ הצטרפת לרשימת ההמתנה!\n\nאיש צוות: ${waitlistEntry.staffName}\nטיפול: ${waitlistEntry.serviceName}\n\nנעדכן אותך כשיתפנה תור.`);
    navigateTo('home');
}

function showAvailableTimes() {
    alert('מציג את התורים הקרובים הזמינים...');
    // In a real app, this would filter and show only available times
}

// ===========================
// Appointments Management
// ===========================
function loadAppointments() {
    const appointmentsList = document.getElementById('appointmentsList');
    
    // Load from localStorage
    const saved = localStorage.getItem('barbershopAppointments');
    if (saved) {
        state.appointments = JSON.parse(saved);
    }
    
    if (state.appointments.length === 0) {
        appointmentsList.innerHTML = `
            <div class="empty-state">
                <svg width="80" height="80" viewBox="0 0 24 24" fill="none">
                    <rect x="3" y="6" width="18" height="15" rx="2" stroke="currentColor" stroke-width="1.5"/>
                    <path d="M3 10h18M8 3v4M16 3v4" stroke="currentColor" stroke-width="1.5"/>
                </svg>
                <p>אין תורים מתוזמנים</p>
                <button class="cta-button" onclick="navigateTo('home')">הזמן תור חדש</button>
            </div>
        `;
        return;
    }
    
    // Sort appointments by date and time
    const sortedAppointments = [...state.appointments].sort((a, b) => {
        return new Date(b.createdAt) - new Date(a.createdAt);
    });
    
    appointmentsList.innerHTML = sortedAppointments.map(apt => `
        <div class="appointment-card">
            <div class="appointment-header">
                <div class="appointment-staff">${apt.staffName}</div>
                <div class="appointment-status">${apt.status === 'confirmed' ? 'מאושר' : 'ממתין'}</div>
            </div>
            <div class="appointment-details">
                <p><strong>טיפול:</strong> ${apt.serviceName}</p>
                <p><strong>תאריך:</strong> ${apt.date}</p>
                <p><strong>שעה:</strong> ${apt.time}</p>
                <p><strong>מחיר:</strong> ₪${apt.servicePrice}</p>
            </div>
            <div class="appointment-actions">
                <button onclick="cancelAppointment(${apt.id})">ביטול תור</button>
                <button onclick="rescheduleAppointment(${apt.id})">שינוי תור</button>
            </div>
        </div>
    `).join('');
}

function saveAppointments() {
    localStorage.setItem('barbershopAppointments', JSON.stringify(state.appointments));
}

function cancelAppointment(appointmentId) {
    if (confirm('האם אתה בטוח שברצונך לבטל את התור?')) {
        state.appointments = state.appointments.filter(apt => apt.id !== appointmentId);
        saveAppointments();
        loadAppointments();
    }
}

function rescheduleAppointment(appointmentId) {
    const appointment = state.appointments.find(apt => apt.id === appointmentId);
    if (appointment) {
        // Pre-fill booking state
        state.booking = {
            staffId: appointment.staffId,
            staffName: appointment.staffName,
            serviceName: appointment.serviceName,
            servicePrice: appointment.servicePrice,
            date: null,
            time: null
        };
        
        // Remove old appointment
        state.appointments = state.appointments.filter(apt => apt.id !== appointmentId);
        saveAppointments();
        
        // Start booking from date selection
        showScreen('selectDateScreen');
    }
}

// ===========================
// Initialize App
// ===========================
function initializeApp() {
    // Set default screen to home
    navigateTo('home');
    
    // Load appointments from localStorage
    const saved = localStorage.getItem('barbershopAppointments');
    if (saved) {
        state.appointments = JSON.parse(saved);
    }
    
    console.log('🚀 BRAVENCE Booking App Initialized');
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', initializeApp);
