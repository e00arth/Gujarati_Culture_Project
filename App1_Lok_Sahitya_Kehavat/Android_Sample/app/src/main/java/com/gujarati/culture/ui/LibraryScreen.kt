package com.gujarati.culture.ui

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
import com.gujarati.culture.models.EBookBook

@Composable
fun LibraryScreen(
    repository: CultureRepository,
    paywallManager: PaywallManager
) {
    val isUnlocked = paywallManager.isModuleUnlocked(CulturalModule.LIBRARY)
    var showPaywall by remember { mutableStateOf(false) }
    var selectedBookForReader by remember { mutableStateOf<EBookBook?>(null) }
    var readerFontSize by remember { mutableStateOf(16.sp) }

    if (selectedBookForReader != null) {
        val book = selectedBookForReader!!
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(onClick = { selectedBookForReader = null }) {
                    Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                }
                Text(book.titleGu, fontWeight = FontWeight.Bold, fontSize = 16.sp)
                Row {
                    IconButton(onClick = { if (readerFontSize.value > 12) readerFontSize = (readerFontSize.value - 2).sp }) {
                        Text("A-", fontWeight = FontWeight.Bold)
                    }
                    IconButton(onClick = { if (readerFontSize.value < 26) readerFontSize = (readerFontSize.value + 2).sp }) {
                        Text("A+", fontWeight = FontWeight.Bold)
                    }
                }
            }

            Divider(modifier = Modifier.padding(vertical = 8.dp))

            Text(book.sampleChapterTitle, fontWeight = FontWeight.Bold, fontSize = (readerFontSize.value + 2).sp, color = MaterialTheme.colorScheme.primary)
            Spacer(modifier = Modifier.height(12.dp))
            Text(book.sampleChapterContent, fontSize = readerFontSize, lineHeight = (readerFontSize.value * 1.5).sp)
        }
    } else {
        Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = Color(0xFFEDE7F6)),
                shape = RoundedCornerShape(12.dp)
            ) {
                Row(
                    modifier = Modifier.padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Icon(
                        Icons.Default.MenuBook,
                        contentDescription = null,
                        tint = Color(0xFF5E35B1),
                        modifier = Modifier.size(36.dp)
                    )
                    Spacer(modifier = Modifier.width(12.dp))
                    Column {
                        Text("અસ્મિતા ડિજિટલ ગ્રંથાલય", fontWeight = FontWeight.Bold, fontSize = 18.sp, color = Color(0xFF4527A0))
                        Text("The 7 Cultural Heritage E-Books & Anthologies", fontSize = 13.sp, color = Color(0xFF5E35B1))
                    }
                }
            }

            Spacer(modifier = Modifier.height(16.dp))

            LazyColumn(
                modifier = Modifier.fillMaxSize(),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                items(repository.libraryBooks) { book ->
                    val bookAccessible = book.isSampleFree || isUnlocked

                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable {
                                if (bookAccessible) {
                                    selectedBookForReader = book
                                } else {
                                    showPaywall = true
                                }
                            },
                        shape = RoundedCornerShape(12.dp),
                        colors = CardDefaults.cardColors(
                            containerColor = if (bookAccessible) MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
                            else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.25f)
                        )
                    ) {
                        Column(modifier = Modifier.padding(16.dp)) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Text(book.titleGu, fontWeight = FontWeight.Bold, fontSize = 17.sp)
                                if (!bookAccessible) {
                                    Row(verticalAlignment = Alignment.CenterVertically) {
                                        Icon(Icons.Default.Lock, contentDescription = "Locked", tint = Color.Gray, modifier = Modifier.size(16.dp))
                                        Spacer(modifier = Modifier.width(4.dp))
                                        Text("LOCKED", fontSize = 11.sp, color = Color.Gray)
                                    }
                                }
                            }

                            Text(book.titleEn, fontSize = 12.sp, color = MaterialTheme.colorScheme.primary)
                            Text("Author / Research: ${book.author} · ${book.fullChaptersCount} Chapters", fontSize = 12.sp, color = Color.Gray)
                            Spacer(modifier = Modifier.height(6.dp))
                            Text(book.summary, fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)

                            Spacer(modifier = Modifier.height(10.dp))
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.End
                            ) {
                                FilledTonalButton(
                                    onClick = {
                                        if (bookAccessible) selectedBookForReader = book
                                        else showPaywall = true
                                    }
                                ) {
                                    Icon(Icons.Default.AutoStories, contentDescription = null, modifier = Modifier.size(16.dp))
                                    Spacer(modifier = Modifier.width(6.dp))
                                    Text(if (bookAccessible) "Read Book" else "Unlock Full Book")
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    if (showPaywall) {
        PaywallBottomSheet(
            module = CulturalModule.LIBRARY,
            paywallManager = paywallManager,
            onDismiss = { showPaywall = false }
        )
    }
}
