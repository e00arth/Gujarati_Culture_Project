package com.gujarati.culture.app2_heritage_audio_map

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme(colorScheme = lightColorScheme(
                primary = Color(0xFF009688), // Teal
                secondary = Color(0xFFFF5722) // Deep Orange
            )) {
                HeritageAudioMapScreen()
            }
        }
    }
}

data class HeritageSite(val name: String, val location: String, val duration: String, val description: String)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HeritageAudioMapScreen() {
    val sites = listOf(
        HeritageSite("Somnath Temple", "Prabhas Patan", "Audio: 15 mins", "The Eternal Shrine. 1st of the 12 Jyotirlingas, symbolizing resilience and the triumph of light over darkness. Known for the Baan-Stambh."),
        HeritageSite("Dwarkadhish Temple", "Dwarka", "Audio: 20 mins", "The Kingdom of Lord Krishna. Translates to 'Door to Liberation'. Built in the Māru-Gurjara style. Near the sunken ancient city."),
        HeritageSite("Ashram of Shrimad Rajchandra", "Dharampur", "Audio: 10 mins", "Spiritual mentor to Mahatma Gandhi, teaching Ahimsa and self-realization."),
        HeritageSite("Jalaram Bapa Mandir", "Virpur", "Audio: 8 mins", "Renowned for the Sadavrat (free feeding center) that operates without taking donations.")
    )

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Heritage Audio Map") },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    titleContentColor = MaterialTheme.colorScheme.onPrimary
                )
            )
        }
    ) { padding ->
        Column(modifier = Modifier.padding(padding).fillMaxSize().background(Color(0xFFF5F5F5))) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(200.dp)
                    .background(Color(0xFFE0F2F1)),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(Icons.Default.LocationOn, contentDescription = "Map", modifier = Modifier.size(64.dp), tint = MaterialTheme.colorScheme.primary)
                    Text("Interactive Map View", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.primary)
                    Text("(GPS tracking enabled)", color = Color.Gray)
                }
            }
            
            Text(
                "Audio Guides Near You",
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(16.dp)
            )

            LazyColumn {
                items(sites) { site ->
                    Card(
                        modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 8.dp),
                        elevation = CardDefaults.cardElevation(2.dp)
                    ) {
                        Column(modifier = Modifier.padding(16.dp)) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(Icons.Default.LocationOn, contentDescription = null, tint = MaterialTheme.colorScheme.secondary)
                                Spacer(modifier = Modifier.width(8.dp))
                                Text(site.name, fontSize = 20.sp, fontWeight = FontWeight.Bold)
                            }
                            Text(site.location, color = Color.Gray, modifier = Modifier.padding(vertical = 4.dp))
                            Text(site.description, modifier = Modifier.padding(vertical = 8.dp))
                            
                            Button(
                                onClick = { /* TODO: Play Audio */ },
                                modifier = Modifier.fillMaxWidth().padding(top = 8.dp),
                                colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.secondary)
                            ) {
                                Icon(Icons.Default.PlayArrow, contentDescription = "Play")
                                Spacer(modifier = Modifier.width(8.dp))
                                Text(site.duration)
                            }
                        }
                    }
                }
            }
        }
    }
}
