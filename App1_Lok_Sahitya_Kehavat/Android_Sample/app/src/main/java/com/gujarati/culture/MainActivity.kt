package com.gujarati.culture

import android.os.Bundle
import android.speech.tts.TextToSpeech
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gujarati.culture.billing.PaywallManager
import com.gujarati.culture.data.CultureRepository
import com.gujarati.culture.models.AppLanguage
import com.gujarati.culture.ui.*
import java.util.Locale

class MainActivity : ComponentActivity(), TextToSpeech.OnInitListener {
    private var tts: TextToSpeech? = null
    private lateinit var repository: CultureRepository
    private lateinit var paywallManager: PaywallManager

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        repository = CultureRepository.getInstance(this)
        paywallManager = PaywallManager.getInstance(this)
        tts = TextToSpeech(this, this)

        setContent {
            MaterialTheme(
                colorScheme = lightColorScheme(
                    primary = Color(0xFFD32F2F),       // Rich Gujarati Saffron-Red
                    secondary = Color(0xFF00897B),     // Teal for Heritage
                    tertiary = Color(0xFFF57C00),      // Deep Orange
                    surfaceVariant = Color(0xFFF5F5F5)
                )
            ) {
                UnifiedHeritageHubApp(
                    repository = repository,
                    paywallManager = paywallManager,
                    tts = tts
                )
            }
        }
    }

    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            tts?.language = Locale("gu", "IN")
        }
    }

    override fun onDestroy() {
        tts?.stop()
        tts?.shutdown()
        super.onDestroy()
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun UnifiedHeritageHubApp(
    repository: CultureRepository,
    paywallManager: PaywallManager,
    tts: TextToSpeech?
) {
    var selectedTab by remember { mutableStateOf(0) }
    var currentLanguage by remember { mutableStateOf(AppLanguage.GUJARATI) }
    var showLanguageMenu by remember { mutableStateOf(false) }

    val tabs = listOf(
        Pair("કહેવતો", Icons.Default.ChatBubbleOutline),
        Pair("લોકસાહિત્ય", Icons.Default.Headphones),
        Pair("તીર્થ દર્શન", Icons.Default.Place),
        Pair("ગ્રંથાલય", Icons.Default.MenuBook),
        Pair("જીવનશૈલી", Icons.Default.Restaurant)
    )

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(
                            text = "ગુજરાત ની અસ્મિતા",
                            fontWeight = FontWeight.Bold,
                            fontSize = 18.sp,
                            color = MaterialTheme.colorScheme.primary
                        )
                        Text(
                            text = "Gujarat Ni Asmita: Heritage Hub",
                            fontSize = 11.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                },
                actions = {
                    // Language Switcher Dropdown
                    Box {
                        TextButton(onClick = { showLanguageMenu = true }) {
                            Icon(Icons.Default.Language, contentDescription = "Language", modifier = Modifier.size(18.dp))
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(currentLanguage.label, fontSize = 13.sp)
                        }
                        DropdownMenu(
                            expanded = showLanguageMenu,
                            onDismissRequest = { showLanguageMenu = false }
                        ) {
                            AppLanguage.values().forEach { lang ->
                                DropdownMenuItem(
                                    text = { Text(lang.label, fontWeight = if (lang == currentLanguage) FontWeight.Bold else FontWeight.Normal) },
                                    onClick = {
                                        currentLanguage = lang
                                        showLanguageMenu = false
                                    }
                                )
                            }
                        }
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = MaterialTheme.colorScheme.surface)
            )
        },
        bottomBar = {
            NavigationBar(tonalElevation = 8.dp) {
                tabs.forEachIndexed { index, pair ->
                    NavigationBarItem(
                        icon = { Icon(pair.second, contentDescription = pair.first) },
                        label = { Text(pair.first, fontSize = 11.sp, fontWeight = if (selectedTab == index) FontWeight.Bold else FontWeight.Normal) },
                        selected = selectedTab == index,
                        onClick = { selectedTab = index }
                    )
                }
            }
        }
    ) { innerPadding ->
        Box(
            modifier = Modifier
                .padding(innerPadding)
                .fillMaxSize()
        ) {
            when (selectedTab) {
                0 -> ProverbsScreen(repository = repository, currentLanguage = currentLanguage)
                1 -> FolkloreScreen(repository = repository, paywallManager = paywallManager, tts = tts)
                2 -> SpiritualScreen(repository = repository, paywallManager = paywallManager)
                3 -> LibraryScreen(repository = repository, paywallManager = paywallManager)
                4 -> LifestyleScreen(repository = repository, paywallManager = paywallManager)
            }
        }
    }
}
