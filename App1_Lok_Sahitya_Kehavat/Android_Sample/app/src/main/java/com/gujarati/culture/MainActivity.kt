package com.gujarati.culture

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
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

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

val sampleFlashcards = listOf(
    Pair("ટીપે ટીપે સરોવર ભરાય", "Drop by drop, a lake is filled. (Small efforts add up)"),
    Pair("લોભે લક્ષણ જાય", "Greed destroys good qualities."),
    Pair("ખાડો ખોદે તે પડે", "He who digs a pit for others falls into it himself.")
)

@Composable
fun FlashcardScreen() {
    var currentIndex by remember { mutableStateOf(0) }
    var isFlipped by remember { mutableStateOf(false) }

    Column(
        modifier = Modifier.fillMaxSize().padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text("Flashcards: Learn Kehavato", fontSize = 24.sp, modifier = Modifier.padding(bottom = 24.dp))
        
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .height(250.dp)
                .clickable { isFlipped = !isFlipped },
            elevation = CardDefaults.cardElevation(8.dp)
        ) {
            Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                if (!isFlipped) {
                    Text(
                        text = "${sampleFlashcards[currentIndex].first}\n\n(Tap to flip)",
                        textAlign = TextAlign.Center, 
                        fontSize = 24.sp,
                        modifier = Modifier.padding(16.dp)
                    )
                } else {
                    Text(
                        text = "${sampleFlashcards[currentIndex].second}\n\n(Tap to flip)",
                        textAlign = TextAlign.Center, 
                        fontSize = 20.sp,
                        color = MaterialTheme.colorScheme.primary,
                        modifier = Modifier.padding(16.dp)
                    )
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
                    if (currentIndex < sampleFlashcards.size - 1) currentIndex++ 
                    isFlipped = false
                },
                enabled = currentIndex < sampleFlashcards.size - 1
            ) { Text("Next") }
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
