package com.gujarati.culture.ui

import android.content.Context
import android.media.MediaPlayer
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gujarati.culture.data.CultureRepository
import com.gujarati.culture.models.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProverbsScreen(
    repository: CultureRepository,
    currentLanguage: AppLanguage
) {
    val context = LocalContext.current
    var query by remember { mutableStateOf("") }
    var selectedCategoryId by remember { mutableStateOf<String?>(null) }
    var favoritesOnly by remember { mutableStateOf(false) }

    // Screen states
    var activeSubScreen by remember { mutableStateOf("list") } // "list", "study", "quiz"
    var selectedKehvatForDetail by remember { mutableStateOf<KehvatItem?>(null) }
    var showDailyDialog by remember { mutableStateOf(false) }

    val filteredList = remember(query, selectedCategoryId, favoritesOnly, repository.favorites.size) {
        repository.filter(query, selectedCategoryId, favoritesOnly)
    }

    when (activeSubScreen) {
        "study" -> {
            StudyFlashcardView(
                repository = repository,
                currentLanguage = currentLanguage,
                onBack = { activeSubScreen = "list" }
            )
        }
        "quiz" -> {
            ProverbQuizView(
                repository = repository,
                currentLanguage = currentLanguage,
                onBack = { activeSubScreen = "list" }
            )
        }
        else -> {
            Column(modifier = Modifier.fillMaxSize()) {
                // Top Action & Search Bar
                Column(modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)) {
                    OutlinedTextField(
                        value = query,
                        onValueChange = { query = it },
                        modifier = Modifier.fillMaxWidth(),
                        placeholder = {
                            Text(
                                when (currentLanguage) {
                                    AppLanguage.GUJARATI -> "શોધો (કહેવત, અર્થ અથવા રોમન)..."
                                    AppLanguage.HINDI -> "खोजें (कहावत, अर्थ या रोमन)..."
                                    AppLanguage.ENGLISH -> "Search proverbs, meaning, or roman..."
                                }
                            )
                        },
                        leadingIcon = { Icon(Icons.Default.Search, contentDescription = "Search") },
                        trailingIcon = {
                            if (query.isNotEmpty()) {
                                IconButton(onClick = { query = "" }) {
                                    Icon(Icons.Default.Clear, contentDescription = "Clear")
                                }
                            }
                        },
                        singleLine = true,
                        shape = RoundedCornerShape(12.dp)
                    )

                    Spacer(modifier = Modifier.height(8.dp))

                    // Buttons Row: Study, Quiz, Daily Proverb, Favorites Filter
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        FilledTonalButton(
                            onClick = { activeSubScreen = "study" },
                            modifier = Modifier.weight(1f),
                            shape = RoundedCornerShape(10.dp)
                        ) {
                            Icon(Icons.Default.School, contentDescription = null, modifier = Modifier.size(18.dp))
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(
                                when (currentLanguage) {
                                    AppLanguage.GUJARATI -> "અભ્યાસ"
                                    AppLanguage.HINDI -> "अध्ययन"
                                    AppLanguage.ENGLISH -> "Study"
                                },
                                fontSize = 13.sp
                            )
                        }

                        FilledTonalButton(
                            onClick = { activeSubScreen = "quiz" },
                            modifier = Modifier.weight(1f),
                            shape = RoundedCornerShape(10.dp)
                        ) {
                            Icon(Icons.Default.Quiz, contentDescription = null, modifier = Modifier.size(18.dp))
                            Spacer(modifier = Modifier.width(4.dp))
                            Text(
                                when (currentLanguage) {
                                    AppLanguage.GUJARATI -> "ક્વિઝ"
                                    AppLanguage.HINDI -> "क्विज़"
                                    AppLanguage.ENGLISH -> "Quiz"
                                },
                                fontSize = 13.sp
                            )
                        }

                        IconButton(onClick = { showDailyDialog = true }) {
                            Icon(Icons.Default.WbSunny, contentDescription = "Daily Proverb", tint = Color(0xFFFF9800))
                        }

                        IconButton(onClick = { favoritesOnly = !favoritesOnly }) {
                            Icon(
                                if (favoritesOnly) Icons.Default.Favorite else Icons.Default.FavoriteBorder,
                                contentDescription = "Favorites",
                                tint = if (favoritesOnly) Color.Red else MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(8.dp))

                    // Category Filter Horizontal Chips
                    LazyRow(
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        item {
                            FilterChip(
                                selected = selectedCategoryId == null,
                                onClick = { selectedCategoryId = null },
                                label = {
                                    Text(
                                        when (currentLanguage) {
                                            AppLanguage.GUJARATI -> "બધા (${repository.allKehvto.size})"
                                            AppLanguage.HINDI -> "सभी (${repository.allKehvto.size})"
                                            AppLanguage.ENGLISH -> "All (${repository.allKehvto.size})"
                                        }
                                    )
                                }
                            )
                        }
                        items(repository.categories) { cat ->
                            FilterChip(
                                selected = selectedCategoryId == cat.id,
                                onClick = {
                                    selectedCategoryId = if (selectedCategoryId == cat.id) null else cat.id
                                },
                                label = { Text(cat.getDisplayName(currentLanguage)) }
                            )
                        }
                    }
                }

                Divider(color = MaterialTheme.colorScheme.surfaceVariant)

                // Proverbs List
                if (filteredList.isEmpty()) {
                    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        Text(
                            when (currentLanguage) {
                                AppLanguage.GUJARATI -> "કોઈ કહેવત મળી નથી"
                                AppLanguage.HINDI -> "कोई कहावत नहीं मिली"
                                AppLanguage.ENGLISH -> "No proverbs found"
                            },
                            color = Color.Gray
                        )
                    }
                } else {
                    LazyColumn(
                        modifier = Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(16.dp),
                        verticalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        items(filteredList, key = { it.id }) { kehvat ->
                            ProverbCardItem(
                                kehvat = kehvat,
                                currentLanguage = currentLanguage,
                                isFavorite = repository.isFavorite(kehvat.id),
                                onToggleFavorite = { repository.toggleFavorite(kehvat.id) },
                                onClick = { selectedKehvatForDetail = kehvat }
                            )
                        }
                    }
                }
            }
        }
    }

    // Detail Dialog
    selectedKehvatForDetail?.let { kehvat ->
        ProverbDetailModal(
            kehvat = kehvat,
            currentLanguage = currentLanguage,
            isFavorite = repository.isFavorite(kehvat.id),
            onToggleFavorite = { repository.toggleFavorite(kehvat.id) },
            onDismiss = { selectedKehvatForDetail = null }
        )
    }

    // Daily Proverb Dialog
    if (showDailyDialog) {
        val daily = repository.allKehvto.firstOrNull()
        daily?.let {
            DailyProverbModal(
                kehvat = it,
                currentLanguage = currentLanguage,
                onDismiss = { showDailyDialog = false }
            )
        }
    }
}

@Composable
fun ProverbCardItem(
    kehvat: KehvatItem,
    currentLanguage: AppLanguage,
    isFavorite: Boolean,
    onToggleFavorite: () -> Unit,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f))
    ) {
        Column(modifier = Modifier.padding(14.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.Top
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = kehvat.text,
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                    if (!kehvat.roman.isNullOrEmpty()) {
                        Text(
                            text = kehvat.roman,
                            fontSize = 13.sp,
                            fontStyle = FontStyle.Italic,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
                IconButton(onClick = onToggleFavorite) {
                    Icon(
                        if (isFavorite) Icons.Default.Favorite else Icons.Default.FavoriteBorder,
                        contentDescription = "Favorite",
                        tint = if (isFavorite) Color.Red else Color.Gray
                    )
                }
            }

            // Quick meaning preview
            val previewMeaning = kehvat.getMeaning(currentLanguage, MeaningLevel.SIMPLE)
                ?: kehvat.getLiteral(currentLanguage)
            if (!previewMeaning.isNullOrEmpty()) {
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text = previewMeaning,
                    fontSize = 14.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 2
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProverbDetailModal(
    kehvat: KehvatItem,
    currentLanguage: AppLanguage,
    isFavorite: Boolean,
    onToggleFavorite: () -> Unit,
    onDismiss: () -> Unit
) {
    var selectedSection by remember { mutableStateOf(DetailSection.NORMAL) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "કહેવત વિગત",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold
                )
                IconButton(onClick = onToggleFavorite) {
                    Icon(
                        if (isFavorite) Icons.Default.Favorite else Icons.Default.FavoriteBorder,
                        contentDescription = "Favorite",
                        tint = if (isFavorite) Color.Red else Color.Gray
                    )
                }
            }
        },
        text = {
            Column(modifier = Modifier.fillMaxWidth()) {
                Text(
                    text = kehvat.text,
                    fontSize = 24.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.primary
                )
                if (kehvat.hindi != null) {
                    Text(kehvat.hindi, fontSize = 16.sp, color = MaterialTheme.colorScheme.secondary)
                }
                Text(
                    text = kehvat.roman,
                    fontSize = 14.sp,
                    fontStyle = FontStyle.Italic,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )

                kehvat.getLiteral(currentLanguage)?.let { lit ->
                    Spacer(modifier = Modifier.height(8.dp))
                    Text("શબ્દશઃ અર્થ: $lit", fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                }

                Spacer(modifier = Modifier.height(14.dp))

                // Section Segmented Buttons (Backstory, Simple, Normal, Advanced, Story)
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceEvenly
                ) {
                    IconButton(
                        onClick = { selectedSection = DetailSection.BACKSTORY },
                        colors = IconButtonDefaults.iconButtonColors(
                            containerColor = if (selectedSection == DetailSection.BACKSTORY) MaterialTheme.colorScheme.primaryContainer else Color.Transparent
                        )
                    ) {
                        Icon(Icons.Default.HistoryEdu, contentDescription = "Backstory", tint = MaterialTheme.colorScheme.primary)
                    }

                    IconButton(
                        onClick = { selectedSection = DetailSection.SIMPLE },
                        colors = IconButtonDefaults.iconButtonColors(
                            containerColor = if (selectedSection == DetailSection.SIMPLE) MaterialTheme.colorScheme.primaryContainer else Color.Transparent
                        )
                    ) {
                        Icon(Icons.Default.SignalCellularAlt1Bar, contentDescription = "Simple")
                    }

                    IconButton(
                        onClick = { selectedSection = DetailSection.NORMAL },
                        colors = IconButtonDefaults.iconButtonColors(
                            containerColor = if (selectedSection == DetailSection.NORMAL) MaterialTheme.colorScheme.primaryContainer else Color.Transparent
                        )
                    ) {
                        Icon(Icons.Default.SignalCellularAlt2Bar, contentDescription = "Normal")
                    }

                    IconButton(
                        onClick = { selectedSection = DetailSection.ADVANCED },
                        colors = IconButtonDefaults.iconButtonColors(
                            containerColor = if (selectedSection == DetailSection.ADVANCED) MaterialTheme.colorScheme.primaryContainer else Color.Transparent
                        )
                    ) {
                        Icon(Icons.Default.SignalCellularAlt, contentDescription = "Advanced")
                    }

                    IconButton(
                        onClick = { selectedSection = DetailSection.STORY },
                        colors = IconButtonDefaults.iconButtonColors(
                            containerColor = if (selectedSection == DetailSection.STORY) MaterialTheme.colorScheme.primaryContainer else Color.Transparent
                        )
                    ) {
                        Icon(Icons.Default.AutoStories, contentDescription = "Story", tint = Color(0xFFE91E63))
                    }
                }

                Divider(modifier = Modifier.padding(vertical = 8.dp))

                // Display Selected Section Content
                val sectionHeading = when (selectedSection) {
                    DetailSection.BACKSTORY -> "સંદર્ભ અને મૂળ (Backstory):"
                    DetailSection.SIMPLE -> "સરળ અર્થ (Simple Meaning):"
                    DetailSection.NORMAL -> "વિગતવાર અર્થ (Normal Meaning):"
                    DetailSection.ADVANCED -> "ઊંડાણપૂર્વક સાહિત્યિક અર્થ (Advanced):"
                    DetailSection.STORY -> "લોકવાર્તા / પ્રસંગ (Folk Tale):"
                }

                val sectionBody = when (selectedSection) {
                    DetailSection.BACKSTORY -> kehvat.getBackstory(currentLanguage) ?: "સંદર્ભ ઉપલબ્ધ નથી"
                    DetailSection.SIMPLE -> kehvat.getMeaning(currentLanguage, MeaningLevel.SIMPLE) ?: "અર્થ ઉપલબ્ધ નથી"
                    DetailSection.NORMAL -> kehvat.getMeaning(currentLanguage, MeaningLevel.NORMAL) ?: "અર્થ ઉપલબ્ધ નથી"
                    DetailSection.ADVANCED -> kehvat.getMeaning(currentLanguage, MeaningLevel.ADVANCED) ?: "અર્થ ઉપલબ્ધ નથી"
                    DetailSection.STORY -> kehvat.getStory(currentLanguage) ?: "વાર્તા ઉપલબ્ધ નથી"
                }

                Text(sectionHeading, fontWeight = FontWeight.Bold, fontSize = 13.sp, color = MaterialTheme.colorScheme.primary)
                Spacer(modifier = Modifier.height(4.dp))
                Text(sectionBody, fontSize = 15.sp, lineHeight = 22.sp)
            }
        },
        confirmButton = {
            TextButton(onClick = onDismiss) {
                Text("Close")
            }
        }
    )
}

@Composable
fun StudyFlashcardView(
    repository: CultureRepository,
    currentLanguage: AppLanguage,
    onBack: () -> Unit
) {
    val items = remember { repository.allKehvto.take(50) }
    var currentIndex by remember { mutableStateOf(0) }
    var isFlipped by remember { mutableStateOf(false) }

    if (items.isEmpty()) {
        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Text("No study cards available")
        }
        return
    }

    val currentItem = items[currentIndex]
    val isMastered = repository.isMastered(currentItem.id)

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(onClick = onBack) {
                Icon(Icons.Default.ArrowBack, contentDescription = "Back")
            }
            Text("Flashcards (${currentIndex + 1}/${items.size})", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
        }

        Spacer(modifier = Modifier.height(24.dp))

        Card(
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f)
                .clickable { isFlipped = !isFlipped },
            shape = RoundedCornerShape(16.dp),
            elevation = CardDefaults.cardElevation(8.dp),
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface)
        ) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(24.dp),
                contentAlignment = Alignment.Center
            ) {
                if (!isFlipped) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(currentItem.text, fontSize = 32.sp, fontWeight = FontWeight.Bold, textAlign = TextAlign.Center, color = MaterialTheme.colorScheme.primary)
                        Spacer(modifier = Modifier.height(12.dp))
                        Text(currentItem.roman, fontStyle = FontStyle.Italic, fontSize = 16.sp, color = Color.Gray)
                        Spacer(modifier = Modifier.height(30.dp))
                        Text("(Tap to flip)", fontSize = 14.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                } else {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text("અર્થ (Meaning)", fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.primary)
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            currentItem.getMeaning(currentLanguage, MeaningLevel.NORMAL)
                                ?: currentItem.getMeaning(currentLanguage, MeaningLevel.SIMPLE)
                                ?: "No meaning",
                            fontSize = 18.sp,
                            textAlign = TextAlign.Center
                        )
                        currentItem.getLiteral(currentLanguage)?.let {
                            Spacer(modifier = Modifier.height(12.dp))
                            Text("Literal: $it", fontStyle = FontStyle.Italic, fontSize = 14.sp, color = Color.Gray)
                        }
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(20.dp))

        // Spaced repetition Leitner buttons: Review Again vs Mastered
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            OutlinedButton(
                onClick = {
                    repository.markStudyStatus(currentItem.id, false)
                    if (currentIndex < items.size - 1) currentIndex++
                    isFlipped = false
                },
                modifier = Modifier.weight(1f),
                colors = ButtonDefaults.outlinedButtonColors(contentColor = Color(0xFFF44336))
            ) {
                Icon(Icons.Default.Refresh, contentDescription = null, modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.width(6.dp))
                Text("Review Again")
            }

            Button(
                onClick = {
                    repository.markStudyStatus(currentItem.id, true)
                    if (currentIndex < items.size - 1) currentIndex++
                    isFlipped = false
                },
                modifier = Modifier.weight(1f),
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF4CAF50))
            ) {
                Icon(Icons.Default.Check, contentDescription = null, modifier = Modifier.size(18.dp))
                Spacer(modifier = Modifier.width(6.dp))
                Text("Mastered")
            }
        }

        Spacer(modifier = Modifier.height(10.dp))

        // Navigation row
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            TextButton(
                onClick = { if (currentIndex > 0) currentIndex--; isFlipped = false },
                enabled = currentIndex > 0
            ) {
                Text("Previous")
            }
            TextButton(
                onClick = { if (currentIndex < items.size - 1) currentIndex++; isFlipped = false },
                enabled = currentIndex < items.size - 1
            ) {
                Text("Next")
            }
        }
    }
}

@Composable
fun ProverbQuizView(
    repository: CultureRepository,
    currentLanguage: AppLanguage,
    onBack: () -> Unit
) {
    var questionIndex by remember { mutableStateOf(0) }
    var score by remember { mutableStateOf(0) }
    var selectedOption by remember { mutableStateOf<String?>(null) }

    // Pick 10 proverbs with meanings for the quiz
    val quizDeck = remember {
        repository.allKehvto.filter { it.hasMeaning() }.shuffled().take(10)
    }

    if (quizDeck.isEmpty()) {
        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            Text("No quiz data available")
        }
        return
    }

    val currentKehvat = quizDeck[questionIndex % quizDeck.size]
    val correctAnswer = currentKehvat.getMeaning(currentLanguage, MeaningLevel.SIMPLE)
        ?: currentKehvat.text

    // Generate 3 distractors
    val options = remember(currentKehvat.id) {
        val distractors = repository.allKehvto
            .filter { it.id != currentKehvat.id && it.hasMeaning() }
            .shuffled()
            .take(3)
            .map { it.getMeaning(currentLanguage, MeaningLevel.SIMPLE) ?: it.text }
        (distractors + correctAnswer).shuffled()
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            IconButton(onClick = onBack) {
                Icon(Icons.Default.ArrowBack, contentDescription = "Back")
            }
            Text("Score: $score / ${quizDeck.size}", fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.primary)
        }

        Spacer(modifier = Modifier.height(20.dp))

        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(12.dp),
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer)
        ) {
            Column(modifier = Modifier.padding(20.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                Text("What does this proverb mean?", fontSize = 14.sp, color = MaterialTheme.colorScheme.onPrimaryContainer)
                Spacer(modifier = Modifier.height(10.dp))
                Text(currentKehvat.text, fontSize = 24.sp, fontWeight = FontWeight.Bold, textAlign = TextAlign.Center)
                Text(currentKehvat.roman, fontStyle = FontStyle.Italic, fontSize = 14.sp, color = Color.Gray)
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        options.forEach { option ->
            val isSelected = selectedOption == option
            val isCorrect = option == correctAnswer

            val containerColor = when {
                selectedOption != null && isCorrect -> Color(0xFF4CAF50)
                isSelected && !isCorrect -> Color(0xFFF44336)
                else -> MaterialTheme.colorScheme.surfaceVariant
            }
            val contentColor = if (selectedOption != null && (isSelected || isCorrect)) Color.White else MaterialTheme.colorScheme.onSurfaceVariant

            Button(
                onClick = {
                    if (selectedOption == null) {
                        selectedOption = option
                        if (isCorrect) score++
                    }
                },
                colors = ButtonDefaults.buttonColors(containerColor = containerColor, contentColor = contentColor),
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 6.dp),
                shape = RoundedCornerShape(10.dp)
            ) {
                Text(option, modifier = Modifier.padding(vertical = 4.dp), textAlign = TextAlign.Center)
            }
        }

        if (selectedOption != null) {
            Spacer(modifier = Modifier.height(16.dp))
            Button(
                onClick = {
                    selectedOption = null
                    if (questionIndex < quizDeck.size - 1) {
                        questionIndex++
                    } else {
                        questionIndex = 0
                        score = 0
                    }
                }
            ) {
                Text(if (questionIndex < quizDeck.size - 1) "Next Question" else "Play Again")
            }
        }
    }
}

@Composable
fun DailyProverbModal(
    kehvat: KehvatItem,
    currentLanguage: AppLanguage,
    onDismiss: () -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Default.WbSunny, contentDescription = null, tint = Color(0xFFFF9800))
                Spacer(modifier = Modifier.width(8.dp))
                Text("આજની કહેવત (Proverb of the Day)", fontWeight = FontWeight.Bold, fontSize = 18.sp)
            }
        },
        text = {
            Column(modifier = Modifier.fillMaxWidth()) {
                Text(kehvat.text, fontSize = 22.sp, fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.primary)
                Text(kehvat.roman, fontStyle = FontStyle.Italic, fontSize = 14.sp, color = Color.Gray)
                Spacer(modifier = Modifier.height(12.dp))
                Text(
                    kehvat.getMeaning(currentLanguage, MeaningLevel.NORMAL)
                        ?: kehvat.getMeaning(currentLanguage, MeaningLevel.SIMPLE)
                        ?: "Patience and virtue guide human prosperity.",
                    fontSize = 15.sp
                )
            }
        },
        confirmButton = {
            Button(onClick = onDismiss) {
                Text("Inspiring!")
            }
        }
    )
}
