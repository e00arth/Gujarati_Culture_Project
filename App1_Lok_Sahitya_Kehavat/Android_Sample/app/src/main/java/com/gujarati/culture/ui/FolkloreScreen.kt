package com.gujarati.culture.ui

import android.speech.tts.TextToSpeech
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gujarati.culture.billing.PaywallManager
import com.gujarati.culture.data.CultureRepository
import com.gujarati.culture.models.CulturalModule
import com.gujarati.culture.models.FolkloreTrack

@Composable
fun FolkloreScreen(
    repository: CultureRepository,
    paywallManager: PaywallManager,
    tts: TextToSpeech?
) {
    val isUnlocked = paywallManager.isModuleUnlocked(CulturalModule.FOLKLORE)
    var showPaywall by remember { mutableStateOf(false) }
    var currentlyPlayingTrackId by remember { mutableStateOf<String?>(null) }
    var selectedTrackForLyrics by remember { mutableStateOf<FolkloreTrack?>(null) }

    Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        // Header Card
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.secondaryContainer),
            shape = RoundedCornerShape(12.dp)
        ) {
            Row(
                modifier = Modifier.padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Default.Headphones,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.secondary,
                    modifier = Modifier.size(36.dp)
                )
                Spacer(modifier = Modifier.width(12.dp))
                Column {
                    Text("લોકસાહિત્ય અને હાલરડાં", fontWeight = FontWeight.Bold, fontSize = 18.sp)
                    Text("Oral Folklore, Lullabies & Rasdhar Narrations", fontSize = 13.sp, color = MaterialTheme.colorScheme.onSecondaryContainer)
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Tracks List
        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            items(repository.folkloreTracks) { track ->
                val trackAccessible = track.isSampleFree || isUnlocked

                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable {
                            if (trackAccessible) {
                                selectedTrackForLyrics = track
                            } else {
                                showPaywall = true
                            }
                        },
                    shape = RoundedCornerShape(12.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = if (trackAccessible) MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
                        else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.25f)
                    )
                ) {
                    Row(
                        modifier = Modifier.padding(14.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        IconButton(
                            onClick = {
                                if (trackAccessible) {
                                    if (currentlyPlayingTrackId == track.id) {
                                        tts?.stop()
                                        currentlyPlayingTrackId = null
                                    } else {
                                        tts?.stop()
                                        tts?.speak(track.lyricsOrText, TextToSpeech.QUEUE_FLUSH, null, track.id)
                                        currentlyPlayingTrackId = track.id
                                    }
                                } else {
                                    showPaywall = true
                                }
                            }
                        ) {
                            Icon(
                                if (!trackAccessible) Icons.Default.Lock
                                else if (currentlyPlayingTrackId == track.id) Icons.Default.Stop
                                else Icons.Default.PlayArrow,
                                contentDescription = "Play/Lock",
                                tint = if (!trackAccessible) Color.Gray else MaterialTheme.colorScheme.primary,
                                modifier = Modifier.size(30.dp)
                            )
                        }

                        Spacer(modifier = Modifier.width(10.dp))

                        Column(modifier = Modifier.weight(1f)) {
                            Text(track.title, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                            Text("${track.category} · ${track.duration}", fontSize = 12.sp, color = Color.Gray)
                            Spacer(modifier = Modifier.height(4.dp))
                            Text(track.description, fontSize = 13.sp, maxLines = 2, color = MaterialTheme.colorScheme.onSurfaceVariant)
                        }

                        if (!trackAccessible) {
                            Surface(
                                color = MaterialTheme.colorScheme.primary,
                                shape = RoundedCornerShape(6.dp)
                            ) {
                                Text("LOCKED", modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp), fontSize = 10.sp, color = Color.White, fontWeight = FontWeight.Bold)
                            }
                        }
                    }
                }
            }
        }
    }

    if (showPaywall) {
        PaywallBottomSheet(
            module = CulturalModule.FOLKLORE,
            paywallManager = paywallManager,
            onDismiss = { showPaywall = false }
        )
    }

    selectedTrackForLyrics?.let { track ->
        AlertDialog(
            onDismissRequest = { selectedTrackForLyrics = null },
            title = { Text(track.title, fontWeight = FontWeight.Bold) },
            text = {
                Column {
                    Text(track.description, fontSize = 13.sp, color = Color.Gray)
                    Divider(modifier = Modifier.padding(vertical = 8.dp))
                    Text(track.lyricsOrText, fontSize = 16.sp, lineHeight = 24.sp)
                }
            },
            confirmButton = {
                Button(onClick = { selectedTrackForLyrics = null }) { Text("Close") }
            }
        )
    }
}
