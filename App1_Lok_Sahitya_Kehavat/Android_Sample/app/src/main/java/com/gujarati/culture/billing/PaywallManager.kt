package com.gujarati.culture.billing

import android.content.Context
import android.content.SharedPreferences
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import com.gujarati.culture.models.CulturalModule

class PaywallManager private constructor(context: Context) {
    private val prefs: SharedPreferences = context.getSharedPreferences("cultural_paywall_prefs", Context.MODE_PRIVATE)

    // Observable map of unlocked modules
    val unlockedModules = mutableStateMapOf<String, Boolean>()
    var isAllAccessUnlocked by mutableStateOf(false)
        private set

    // Toggle for easy developer/reviewer testing
    var isTestingMode by mutableStateOf(false)

    init {
        loadEntitlements()
    }

    private fun loadEntitlements() {
        isAllAccessUnlocked = prefs.getBoolean(CulturalModule.BUNDLE_ALL_ACCESS, false)
        for (module in CulturalModule.values()) {
            if (module.isFree) {
                unlockedModules[module.id] = true
            } else {
                unlockedModules[module.id] = isAllAccessUnlocked || prefs.getBoolean(module.id, false)
            }
        }
    }

    fun isModuleUnlocked(module: CulturalModule): Boolean {
        if (module.isFree || isAllAccessUnlocked) return true
        return unlockedModules[module.id] == true
    }

    fun unlockModule(module: CulturalModule) {
        prefs.edit().putBoolean(module.id, true).apply()
        unlockedModules[module.id] = true
    }

    fun unlockAllAccess() {
        prefs.edit().putBoolean(CulturalModule.BUNDLE_ALL_ACCESS, true).apply()
        isAllAccessUnlocked = true
        for (module in CulturalModule.values()) {
            unlockedModules[module.id] = true
        }
    }

    fun lockModule(module: CulturalModule) {
        if (module.isFree) return
        prefs.edit().putBoolean(module.id, false).apply()
        unlockedModules[module.id] = false
        prefs.edit().putBoolean(CulturalModule.BUNDLE_ALL_ACCESS, false).apply()
        isAllAccessUnlocked = false
    }

    fun resetAllPurchases() {
        prefs.edit().clear().apply()
        loadEntitlements()
    }

    companion object {
        @Volatile
        private var instance: PaywallManager? = null

        fun getInstance(context: Context): PaywallManager {
            return instance ?: synchronized(this) {
                instance ?: PaywallManager(context.applicationContext).also { instance = it }
            }
        }
    }
}
