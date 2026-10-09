package com.gujarati.culture.app4_culture_lifestyle

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.ShoppingCart
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme(colorScheme = lightColorScheme(
                primary = androidx.compose.ui.graphics.Color(0xFFE91E63), // Vibrant pink/red
                secondary = androidx.compose.ui.graphics.Color(0xFFFFC107) // Yellow
            )) {
                LifestyleAppScreen()
            }
        }
    }
}

@Composable
fun LifestyleAppScreen() {
    var selectedTab by remember { mutableStateOf(0) }
    val tabs = listOf("Dietary", "Attire", "Festivals")
    val icons = listOf(Icons.Default.ShoppingCart, Icons.Default.Info, Icons.Default.Star)

    Scaffold(
        topBar = {
            @OptIn(ExperimentalMaterial3Api::class)
            TopAppBar(
                title = { Text("Asmita Lifestyle") },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    titleContentColor = MaterialTheme.colorScheme.onPrimary
                )
            )
        },
        bottomBar = {
            NavigationBar {
                tabs.forEachIndexed { index, title ->
                    NavigationBarItem(
                        icon = { Icon(icons[index], contentDescription = title) },
                        label = { Text(title) },
                        selected = selectedTab == index,
                        onClick = { selectedTab = index }
                    )
                }
            }
        }
    ) { innerPadding ->
        Box(modifier = Modifier.padding(innerPadding).fillMaxSize()) {
            when (selectedTab) {
                0 -> DietScreen()
                1 -> AttireScreen()
                2 -> FestivalScreen()
            }
        }
    }
}

@Composable
fun SectionCard(title: String, history: String, meaning: String, facts: List<String>) {
    Card(
        modifier = Modifier.fillMaxWidth().padding(16.dp),
        elevation = CardDefaults.cardElevation(4.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(title, fontSize = 22.sp, fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.primary)
            Spacer(modifier = Modifier.height(8.dp))
            Text("History:", fontWeight = FontWeight.Bold)
            Text(history, style = MaterialTheme.typography.bodyMedium)
            Spacer(modifier = Modifier.height(8.dp))
            Text("Deep Meaning:", fontWeight = FontWeight.Bold)
            Text(meaning, style = MaterialTheme.typography.bodyMedium)
            Spacer(modifier = Modifier.height(8.dp))
            Text("Interesting Facts:", fontWeight = FontWeight.Bold)
            facts.forEach { fact ->
                Text("• $fact", style = MaterialTheme.typography.bodyMedium)
            }
        }
    }
}

@Composable
fun DietScreen() {
    Column(modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState())) {
        SectionCard(
            title = "Gujarati Thali & Ayurvedic Wisdom",
            history = "Evolved over 2,000 years. Strong vegetarianism rooted in Jain principles of Ahimsa and Vaishnavism. Mercantile history shaped travel-friendly foods like Thepla and Farsan.",
            meaning = "Holistic system incorporating the Six Tastes (Shad Rasa). Spices keep the digestive fire (Agni) strong. Adapted to seasonality.",
            facts = listOf(
                "Sweetness counters the historical high salinity of coastal water.",
                "Thali balances liquid Kadhi with solid Rotli, preventing sluggishness."
            )
        )
    }
}

@Composable
fun AttireScreen() {
    Column(modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState())) {
        SectionCard(
            title = "Chaniya Choli & Kediyu",
            history = "Traced back to rural/pastoral groups like Rabari. Evolved from practical arid clothing to embellished festive wear.",
            meaning = "Designed for graceful swirling in Garba. Red colors mean fertility/brides; yellow means motherhood. Kediyu frills mirror women's skirts for visual symmetry.",
            facts = listOf(
                "Abla (mirror) work was originally to ward off the evil eye.",
                "Heer Bharat uses untwisted silk floss for geometric patterns."
            )
        )
    }
}

@Composable
fun FestivalScreen() {
    Column(modifier = Modifier.fillMaxSize().verticalScroll(rememberScrollState())) {
        SectionCard(
            title = "Navratri",
            history = "Meaning 'nine nights'. Celebrates Goddess Durga's victory over the demon Mahishasura.",
            meaning = "Dancers circle the Garbo (pot with lamp) representing the womb and divine light, symbolizing the cycle of life.",
            facts = listOf("Longest organized dance festival in the world.")
        )
        SectionCard(
            title = "Uttarayan",
            history = "Marks the sun's transition northward on Jan 14. Agrarian thanksgiving.",
            meaning = "Ascension from darkness to light. Time for renewing community ties.",
            facts = listOf(
                "Rooftops become the center of society for kite battles.",
                "Eaten with Undhiyu (cooked underground) and Chikki.",
                "Auspicious time for heavy charity (Daan)."
            )
        )
    }
}
