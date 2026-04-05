
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqliteService {
  static Future<Database> init() async {
    return openDatabase(
      join(await getDatabasesPath(), 'agrolink.db'),
      version: 5,
      onCreate: (db, version) async {
        await _createAllTables(db);
        await _migrateToV4(db);
        await _migrateToV5(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createV2Tables(db);
        }
        if (oldVersion < 3) {
          await _migrateToV3(db);
        }
        if (oldVersion < 4) {
          await _migrateToV4(db);
        }
        if (oldVersion < 5) {
          await _migrateToV5(db);
        }
      },
    );
  }

  static Future<void> _createAllTables(Database db) async {
    // --- v1 tables ---
    await db.execute('''
      CREATE TABLE loans(
        id TEXT PRIMARY KEY,
        farmerId TEXT,
        amount REAL,
        status TEXT,
        createdAt TEXT,
        isSynced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE loan_offers(
        id TEXT PRIMARY KEY,
        lenderName TEXT NOT NULL,
        interestRate REAL NOT NULL,
        amount REAL NOT NULL,
        repaymentPeriod TEXT NOT NULL,
        monthlyPayment REAL NOT NULL,
        conditions TEXT NOT NULL,
        isRecommended INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue(
        id TEXT PRIMARY KEY,
        type TEXT,
        payload TEXT,
        retryCount INTEGER DEFAULT 0,
        lastAttemptedAt TEXT
      )
    ''');

    // --- v2 tables ---
    await _createV2Tables(db);
  }

  static Future<void> _createV2Tables(Database db) async {
    // ─── Farms ────────────────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS farms(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        farmerId TEXT NOT NULL,
        totalHectares REAL,
        region TEXT,
        soilType TEXT,
        waterSource TEXT,
        latitude REAL,
        longitude REAL,
        address TEXT,
        isSynced INTEGER DEFAULT 0,
        updatedAt TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS farm_fields(
        id TEXT PRIMARY KEY,
        farmId TEXT NOT NULL,
        name TEXT NOT NULL,
        hectares REAL,
        currentCrop TEXT,
        season TEXT,
        status TEXT,
        yieldTonnes REAL,
        isSynced INTEGER DEFAULT 0,
        FOREIGN KEY (farmId) REFERENCES farms(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS field_expenses(
        id TEXT PRIMARY KEY,
        fieldId TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        isSynced INTEGER DEFAULT 0,
        FOREIGN KEY (fieldId) REFERENCES farm_fields(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS livestock_records(
        id TEXT PRIMARY KEY,
        farmId TEXT NOT NULL,
        type TEXT NOT NULL,
        tagNumber TEXT,
        name TEXT,
        breed TEXT,
        sex TEXT,
        dateOfBirth TEXT,
        weight REAL,
        status TEXT DEFAULT 'active',
        isSynced INTEGER DEFAULT 0,
        FOREIGN KEY (farmId) REFERENCES farms(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS vet_events(
        id TEXT PRIMARY KEY,
        livestockId TEXT NOT NULL,
        type TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        administeredBy TEXT,
        isSynced INTEGER DEFAULT 0,
        FOREIGN KEY (livestockId) REFERENCES livestock_records(id) ON DELETE CASCADE
      )
    ''');

    // ─── Savings Groups ───────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS savings_groups(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        contributionAmount REAL,
        frequency TEXT,
        memberCount INTEGER,
        totalSaved REAL DEFAULT 0,
        nextPayoutDate TEXT,
        nextPayoutMember TEXT,
        createdAt TEXT,
        isSynced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS savings_transactions(
        id TEXT PRIMARY KEY,
        groupId TEXT NOT NULL,
        memberId TEXT,
        memberName TEXT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        isConfirmed INTEGER DEFAULT 0,
        isSynced INTEGER DEFAULT 0,
        FOREIGN KEY (groupId) REFERENCES savings_groups(id) ON DELETE CASCADE
      )
    ''');

    // ─── Cooperatives & Group Orders ──────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cooperatives(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        region TEXT,
        memberCount INTEGER,
        category TEXT,
        isSynced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS group_orders(
        id TEXT PRIMARY KEY,
        cooperativeId TEXT NOT NULL,
        productName TEXT NOT NULL,
        supplier TEXT,
        unitPrice REAL,
        bulkPrice REAL,
        minimumQuantity INTEGER,
        currentQuantity INTEGER DEFAULT 0,
        unit TEXT,
        deadline TEXT,
        status TEXT DEFAULT 'open',
        isSynced INTEGER DEFAULT 0,
        FOREIGN KEY (cooperativeId) REFERENCES cooperatives(id) ON DELETE CASCADE
      )
    ''');

    // ─── Contracts ────────────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS farming_contracts(
        id TEXT PRIMARY KEY,
        buyerName TEXT NOT NULL,
        buyerType TEXT,
        commodity TEXT NOT NULL,
        pricePerUnit REAL,
        unit TEXT,
        minQuantity INTEGER,
        season TEXT,
        region TEXT,
        requirements TEXT,
        buyerProvides TEXT,
        deadline TEXT,
        status TEXT DEFAULT 'open',
        isSynced INTEGER DEFAULT 0
      )
    ''');

    // ─── Weather Alerts (cached) ──────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS weather_alerts(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        severity TEXT,
        region TEXT,
        validFrom TEXT,
        validTo TEXT,
        actionAdvice TEXT,
        fetchedAt TEXT
      )
    ''');

    // ─── Diagnosis History ────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS diagnosis_results(
        id TEXT PRIMARY KEY,
        imagePath TEXT,
        type TEXT,
        timestamp TEXT NOT NULL,
        topMatchName TEXT,
        topMatchConfidence REAL,
        topMatchSeverity TEXT,
        topMatchTreatment TEXT,
        isSynced INTEGER DEFAULT 0
      )
    ''');

    // ─── Farm Inputs (cached catalogue) ───────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS farm_inputs(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT,
        supplier TEXT,
        price REAL,
        bulkPrice REAL,
        unit TEXT,
        description TEXT,
        isVerified INTEGER DEFAULT 0,
        imageUrl TEXT,
        updatedAt TEXT
      )
    ''');

    // ─── Subsidy Applications ─────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS subsidy_applications(
        id TEXT PRIMARY KEY,
        programId TEXT NOT NULL,
        programName TEXT,
        status TEXT DEFAULT 'submitted',
        appliedAt TEXT,
        isSynced INTEGER DEFAULT 0
      )
    ''');

    // ─── Commodity Prices (cached) ────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS commodity_prices(
        id TEXT PRIMARY KEY,
        commodityName TEXT NOT NULL,
        category TEXT,
        unit TEXT,
        price REAL,
        previousPrice REAL,
        fetchedAt TEXT
      )
    ''');

    // ─── Notifications ──────────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS notifications(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        isRead INTEGER DEFAULT 0,
        actionRoute TEXT
      )
    ''');

    // ─── Farm Profile ───────────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS farm_profile(
        id TEXT PRIMARY KEY,
        data TEXT NOT NULL
      )
    ''');

    // ─── Marketplace Listings ────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS marketplace_listings(
        id TEXT PRIMARY KEY,
        produceName TEXT NOT NULL,
        category TEXT NOT NULL,
        quantity REAL NOT NULL,
        pricePerUnit REAL NOT NULL,
        location TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        isSynced INTEGER DEFAULT 0
      )
    ''');

    // ─── Indexes ──────────────────────────────────────────
    await db.execute('CREATE INDEX IF NOT EXISTS idx_farm_fields_farmId ON farm_fields(farmId)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_field_expenses_fieldId ON field_expenses(fieldId)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_livestock_farmId ON livestock_records(farmId)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_vet_events_livestockId ON vet_events(livestockId)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_savings_tx_groupId ON savings_transactions(groupId)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_group_orders_coopId ON group_orders(cooperativeId)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_sync_queue_type ON sync_queue(type)');
  }

  static Future<void> _migrateToV3(Database db) async {
    await db.execute(
      'ALTER TABLE sync_queue ADD COLUMN lastAttemptedAt TEXT',
    );
    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_metadata(
        collection TEXT PRIMARY KEY,
        lastSyncAt TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _migrateToV4(Database db) async {
    // ─── Labor Management ──────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS farm_workers(
        id TEXT PRIMARY KEY,
        farmId TEXT NOT NULL,
        name TEXT NOT NULL,
        role TEXT,
        dailyWage REAL,
        phone TEXT,
        isSynced INTEGER DEFAULT 0
      )
    ''');
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS farm_tasks(
        id TEXT PRIMARY KEY,
        farmId TEXT NOT NULL,
        name TEXT NOT NULL,
        assignedWorkerId TEXT,
        date TEXT,
        status TEXT DEFAULT 'pending',
        estimatedCost REAL,
        isSynced INTEGER DEFAULT 0,
        FOREIGN KEY (assignedWorkerId) REFERENCES farm_workers(id) ON DELETE SET NULL
      )
    ''');

    // ─── IoT Devices ───────────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS iot_sensors(
        id TEXT PRIMARY KEY,
        farmId TEXT,
        name TEXT NOT NULL,
        type TEXT,
        status TEXT,
        battery INTEGER,
        currentValue TEXT,
        trend TEXT,
        lastUpdated TEXT,
        isSynced INTEGER DEFAULT 0
      )
    ''');

    // ─── Community Forum ───────────────────────────────────
    await db.execute('''
      CREATE TABLE IF NOT EXISTS forum_posts(
        id TEXT PRIMARY KEY,
        author TEXT,
        region TEXT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        replies INTEGER DEFAULT 0,
        tagsData TEXT,
        isAlert INTEGER DEFAULT 0,
        time TEXT NOT NULL,
        isSynced INTEGER DEFAULT 0
      )
    ''');
  }

  static Future<void> _migrateToV5(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS service_partners(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        subtitle TEXT,
        iconCode TEXT,
        colorHex TEXT,
        route TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS marketplace_products(
        id TEXT PRIMARY KEY,
        sellerId TEXT,
        title TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        category TEXT,
        imageUrls TEXT,
        postedAt TEXT NOT NULL,
        isSynced INTEGER DEFAULT 0
      )
    ''');
  }
}
