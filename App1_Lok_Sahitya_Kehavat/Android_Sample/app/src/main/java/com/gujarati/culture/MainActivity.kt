package com.gujarati.culture

import android.content.Context
import android.media.MediaPlayer
import androidx.compose.ui.platform.LocalContext
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewmodel.compose.viewModel
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.DateRange
import androidx.compose.material.icons.filled.List
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                MainScreen()
            }
        }
    }
}

@Composable
fun MainScreen() {
    var selectedTab by remember { mutableStateOf(0) }
    val tabs = listOf("Daily", "Flashcards", "Quiz")
    val icons = listOf(Icons.Default.DateRange, Icons.Default.List, Icons.Default.Star)

    Scaffold(
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
                0 -> KehavatScreen()
                1 -> FlashcardScreen()
                2 -> QuizScreen()
            }
        }
    }
}

@Composable
fun KehavatScreen() {
    Column(
        modifier = Modifier.fillMaxSize().padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text("Proverb of the Day", fontSize = 24.sp, color = MaterialTheme.colorScheme.primary, modifier = Modifier.padding(bottom = 32.dp))
        Card(modifier = Modifier.fillMaxWidth(), elevation = CardDefaults.cardElevation(4.dp)) {
            Column(modifier = Modifier.padding(24.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                Text("ઉતાવળે આંબા ન પાકે", fontSize = 28.sp, textAlign = TextAlign.Center, modifier = Modifier.padding(bottom = 16.dp))
                Text("Utavle aamba na paake", fontStyle = FontStyle.Italic, modifier = Modifier.padding(bottom = 8.dp))
                Text("Mangoes do not ripen in a hurry. Patience yields sweet results.", textAlign = TextAlign.Center, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
        }
    }
}



class FlashcardViewModel : ViewModel() {
    var words by mutableStateOf<List<GujaratiWord>>(emptyList())
    var isLoading by mutableStateOf(true)

    fun fetchWords(context: Context) {
        isLoading = true
        try {
            DictionaryManager.init(context)
            words = DictionaryManager.getRandomWords(10)
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            isLoading = false
        }
    }

    fun playAudio(context: Context, wordId: String) {
        try {
            val mediaPlayer = MediaPlayer()
            val afd = context.assets.openFd("audio/words/$wordId.mp3")
            mediaPlayer.setDataSource(afd.fileDescriptor, afd.startOffset, afd.length)
            mediaPlayer.prepare()
            mediaPlayer.start()
            mediaPlayer.setOnCompletionListener {
                it.release()
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}

@Composable
fun FlashcardScreen(viewModel: FlashcardViewModel = viewModel()) {
    val context = LocalContext.current
    var currentIndex by remember { mutableStateOf(0) }
    var isFlipped by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {
        if (viewModel.words.isEmpty()) {
            viewModel.fetchWords(context)
        }
    }

    Column(
        modifier = Modifier.fillMaxSize().padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text("Flashcards: Learn Vocabulary", fontSize = 24.sp, modifier = Modifier.padding(bottom = 24.dp))
        
        if (viewModel.isLoading) {
            CircularProgressIndicator()
        } else if (viewModel.words.isEmpty()) {
            Text("Failed to load words.")
            Button(onClick = { viewModel.fetchWords(context) }, modifier = Modifier.padding(top = 16.dp)) {
                Text("Retry")
            }
        } else {
            val currentWord = viewModel.words[currentIndex]
            
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(300.dp)
                    .clickable { isFlipped = !isFlipped },
                elevation = CardDefaults.cardElevation(8.dp)
            ) {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    if (!isFlipped) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.padding(16.dp)) {
                            Text(text = currentWord.word, fontSize = 36.sp, color = MaterialTheme.colorScheme.primary)
                            Spacer(modifier = Modifier.height(16.dp))
                            Text(text = "(Tap to flip)", fontSize = 16.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                            
                            Spacer(modifier = Modifier.height(16.dp))
                            IconButton(onClick = { viewModel.playAudio(context, currentWord.id) }) {
                                Icon(Icons.Default.PlayArrow, contentDescription = "Play Pronunciation")
                            }
                        }
                    } else {
                        Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.padding(16.dp)) {
                            val definition = currentWord.definitions.firstOrNull()?.definition ?: "No definition"
                            Text(text = "${currentWord.romanization} (${currentWord.ipa})", fontStyle = FontStyle.Italic, fontSize = 18.sp)
                            Spacer(modifier = Modifier.height(16.dp))
                            Text(text = definition, textAlign = TextAlign.Center, fontSize = 20.sp)
                            Spacer(modifier = Modifier.height(16.dp))
                            Text(text = "(Tap to flip)", fontSize = 14.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                        }
                    }
                }
            }
            
            Spacer(modifier = Modifier.height(32.dp))
            
            Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                OutlinedButton(
                    onClick = { 
                        if (currentIndex > 0) currentIndex--
                        isFlipped = false 
                    },
                    enabled = currentIndex > 0
                ) { Text("Previous") }
                
                Button(
                    onClick = { 
                        if (currentIndex < viewModel.words.size - 1) currentIndex++ 
                        isFlipped = false
                    },
                    enabled = currentIndex < viewModel.words.size - 1
                ) { Text("Next") }
            }
        }
    }
}

@Composable
fun QuizScreen() {
    var selectedOption by remember { mutableStateOf<String?>(null) }
    val correctOption = "As you sow, so shall you reap"
    val options = listOf("As you sow, so shall you reap", "Look before you leap", "Patience is key", "Every drop counts")

    Column(
        modifier = Modifier.fillMaxSize().padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text("Daily Quiz", fontSize = 24.sp, modifier = Modifier.padding(bottom = 24.dp))
        Text("What does 'જેવું વાવો તેવું લણો' mean?", fontSize = 20.sp, textAlign = TextAlign.Center, modifier = Modifier.padding(bottom = 24.dp))
        
        options.forEach { option ->
            val isSelected = option == selectedOption
            val isCorrect = option == correctOption
            
            val containerColor = when {
                isSelected && isCorrect -> androidx.compose.ui.graphics.Color(0xFF4CAF50) // Green
                isSelected && !isCorrect -> androidx.compose.ui.graphics.Color(0xFFF44336) // Red
                selectedOption != null && isCorrect -> androidx.compose.ui.graphics.Color(0xFF4CAF50) // Reveal correct
                else -> MaterialTheme.colorScheme.surfaceVariant
            }
            val contentColor = if (selectedOption != null && (isSelected || isCorrect)) androidx.compose.ui.graphics.Color.White else MaterialTheme.colorScheme.onSurfaceVariant

            Button(
                onClick = { if (selectedOption == null) selectedOption = option },
                colors = ButtonDefaults.buttonColors(containerColor = containerColor, contentColor = contentColor),
                modifier = Modifier.fillMaxWidth().padding(vertical = 8.dp)
            ) {
                Text(option, modifier = Modifier.padding(8.dp))
            }
        }
        
        if (selectedOption != null) {
            Spacer(modifier = Modifier.height(16.dp))
            Button(onClick = { selectedOption = null }) {
                Text("Next Question")
            }
        }
    }
}
