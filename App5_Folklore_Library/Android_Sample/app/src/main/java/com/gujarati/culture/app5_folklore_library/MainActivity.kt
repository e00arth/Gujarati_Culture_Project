package com.gujarati.culture.app5_folklore_library

import android.os.Bundle
import android.speech.tts.TextToSpeech
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import java.util.Locale

class MainActivity : ComponentActivity(), TextToSpeech.OnInitListener {
    private var tts: TextToSpeech? = null
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Initialize TextToSpeech
        tts = TextToSpeech(this, this)
        
        setContent {
            MaterialTheme {
                FolkloreAppScreen(
                    onPlay = { text -> 
                        tts?.speak(text, TextToSpeech.QUEUE_FLUSH, null, "") 
                    },
                    onStop = {
                        tts?.stop()
                    }
                )
            }
        }
    }

    override fun onInit(status: Int) {
        if (status == TextToSpeech.SUCCESS) {
            // Try to set Gujarati locale, fallback to English or Hindi if not available
            val gujaratiLocale = Locale("gu", "IN")
            val result = tts?.setLanguage(gujaratiLocale)
            
            if (result == TextToSpeech.LANG_MISSING_DATA || result == TextToSpeech.LANG_NOT_SUPPORTED) {
                tts?.setLanguage(Locale("hi", "IN")) // fallback
            }
        }
    }

    override fun onDestroy() {
        if (tts != null) {
            tts?.stop()
            tts?.shutdown()
        }
        super.onDestroy()
    }
}

data class Track(val title: String, val category: String, val duration: String, val script: String)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FolkloreAppScreen(onPlay: (String) -> Unit, onStop: () -> Unit) {
    val tracks = listOf(
        Track("Shivaji Nu Halardu", "Lullaby", "4:30", "આભમાં ઊગેલ ચાંદલો, ને જીજાબાઇને આવ્યાં બાળ રે. શિવાજીને નીંદરું નાવે."),
        Track("Dhammak Dhammak", "Story", "12:15", "ધમ્મક ધમ્મક આવે હાથી. હાથી ભાઈ તો જાડા લાગે મોટા પાડા."),
        Track("Kumkum Pagle", "Music", "6:45", "કુમકુમ પગલે માડી પધારો રે. ગરબે ઘૂમવા આવો રે."),
        Track("Dikri Mari Ladakvayi", "Lullaby", "5:20", "દીકરી મારી લાડકવાયી લક્ષ્મી નો અવતાર. એ સુએ તો રાત પડે ને જાગે તો સવાર."),
        Track("Saurashtra Ni Rasdhar", "Audiobook", "45:00", "સૌરાષ્ટ્રની રસધાર. લેખક ઝવેરચંદ મેઘાણી. ભાગ પહેલો.")
    )
    
    var selectedTrack by remember { mutableStateOf<Track?>(null) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Gujarati Folklore Library") },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primaryContainer,
                    titleContentColor = MaterialTheme.colorScheme.onPrimaryContainer
                )
            )
        }
    ) { padding ->
        Column(modifier = Modifier.padding(padding).fillMaxSize()) {
            LazyColumn(modifier = Modifier.weight(1f)) {
                items(tracks) { track ->
                    ListItem(
                        headlineContent = { Text(track.title) },
                        supportingContent = { Text(track.category) },
                        trailingContent = { Text(track.duration) },
                        leadingContent = {
                            Icon(Icons.Default.PlayArrow, contentDescription = "Play")
                        },
                        modifier = Modifier.clickable { 
                            selectedTrack = track
                            onPlay(track.script)
                        }
                    )
                    Divider()
                }
            }
            
            selectedTrack?.let { track ->
                AudioPlayerBar(track = track, onClose = { 
                    selectedTrack = null
                    onStop()
                })
            }
        }
    }
}

@Composable
fun AudioPlayerBar(track: Track, onClose: () -> Unit) {
    Surface(
        color = MaterialTheme.colorScheme.secondaryContainer,
        modifier = Modifier.fillMaxWidth()
    ) {
        Row(
            modifier = Modifier.padding(16.dp).fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(track.title, style = MaterialTheme.typography.titleMedium)
                Text("Now Playing...", style = MaterialTheme.typography.bodySmall)
                LinearProgressIndicator(modifier = Modifier.fillMaxWidth().padding(top = 8.dp))
            }
            IconButton(onClick = onClose) {
                Icon(Icons.Default.Close, contentDescription = "Close Player")
            }
        }
    }
}
