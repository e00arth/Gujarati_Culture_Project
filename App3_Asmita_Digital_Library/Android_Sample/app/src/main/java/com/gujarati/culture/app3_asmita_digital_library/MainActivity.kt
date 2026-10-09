package com.gujarati.culture.app3_asmita_digital_library

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.material.icons.filled.Info
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack

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
                primary = Color(0xFF673AB7), // Deep Purple
                secondary = Color(0xFFFF9800) // Orange
            )) {
                DigitalLibraryApp()
            }
        }
    }
}

data class EBook(val title: String, val author: String, val contentPreview: String)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DigitalLibraryApp() {
    var selectedBook by remember { mutableStateOf<EBook?>(null) }
    
    val library = listOf(
        EBook("Gujarati Kehavato", "Traditional", "A collection of proverbs... ટીપે ટીપે સરોવર ભરાય."),
        EBook("Lok Sahitya", "Jhaverchand Meghani", "Transcriptions of oral folklore..."),
        EBook("Spiritual Heritage", "Historical", "The Eternal Shrine of Somnath..."),
        EBook("Makers of Modern Gujarat", "Biographical", "Biographies of social reformers..."),
        EBook("Journey of Language Pt1", "Linguistic Studies", "The roots of the Gujarati language lie in the ancient Indo-Aryan family. It evolved from Sanskrit through Prakrit and Apabhramsha into Old Gujarati (1100–1500 CE). The Gurjara people significantly influenced the linguistic landscape, eventually giving the language its name. Fascinatingly, Gujarati has a highly layered lexicon, borrowing not just from Persian and Arabic due to historical trade and conquests, but also retaining deep vernacular structures unique to its geographical isolation.")
    )

    if (selectedBook == null) {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = { Text("Asmita Digital Library") },
                    colors = TopAppBarDefaults.topAppBarColors(
                        containerColor = MaterialTheme.colorScheme.primary,
                        titleContentColor = MaterialTheme.colorScheme.onPrimary
                    )
                )
            }
        ) { padding ->
            Column(modifier = Modifier.padding(padding).fillMaxSize()) {
                LazyVerticalGrid(
                    columns = GridCells.Fixed(2),
                    contentPadding = PaddingValues(16.dp),
                    horizontalArrangement = Arrangement.spacedBy(16.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    items(library) { book ->
                        Card(
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(180.dp)
                                .clickable { selectedBook = book },
                            elevation = CardDefaults.cardElevation(4.dp),
                            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)
                        ) {
                            Column(
                                modifier = Modifier.padding(16.dp).fillMaxSize(),
                                horizontalAlignment = Alignment.CenterHorizontally,
                                verticalArrangement = Arrangement.Center
                            ) {
                                Icon(Icons.Default.Info, contentDescription = null, modifier = Modifier.size(48.dp), tint = MaterialTheme.colorScheme.primary)
                                Spacer(modifier = Modifier.height(16.dp))
                                Text(book.title, fontWeight = FontWeight.Bold, fontSize = 16.sp, color = MaterialTheme.colorScheme.onSurface, textAlign = androidx.compose.ui.text.style.TextAlign.Center)
                                Text(book.author, fontSize = 12.sp, color = Color.Gray)
                            }
                        }
                    }
                }
            }
        }
    } else {
        // Reader Screen
        Scaffold(
            topBar = {
                TopAppBar(
                    title = { Text(selectedBook!!.title) },
                    navigationIcon = {
                        IconButton(onClick = { selectedBook = null }) {
                            Icon(Icons.Default.ArrowBack, contentDescription = "Back", tint = MaterialTheme.colorScheme.onPrimary)
                        }
                    },
                    colors = TopAppBarDefaults.topAppBarColors(
                        containerColor = MaterialTheme.colorScheme.primary,
                        titleContentColor = MaterialTheme.colorScheme.onPrimary
                    )
                )
            }
        ) { padding ->
            Column(
                modifier = Modifier
                    .padding(padding)
                    .fillMaxSize()
                    .padding(16.dp)
                    .verticalScroll(rememberScrollState())
            ) {
                Text(selectedBook!!.title, fontSize = 28.sp, fontWeight = FontWeight.Bold)
                Text("By ${selectedBook!!.author}", fontSize = 16.sp, color = Color.Gray, modifier = Modifier.padding(bottom = 24.dp))
                
                Text(
                    text = selectedBook!!.contentPreview,
                    fontSize = 18.sp,
                    lineHeight = 28.sp,
                    color = MaterialTheme.colorScheme.onSurface
                )
            }
        }
    }
}
