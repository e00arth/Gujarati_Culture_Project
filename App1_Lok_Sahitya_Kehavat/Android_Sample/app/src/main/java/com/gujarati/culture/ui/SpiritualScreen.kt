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
import com.gujarati.culture.models.SpiritualSite

@Composable
fun SpiritualScreen(
    repository: CultureRepository,
    paywallManager: PaywallManager
) {
    val isUnlocked = paywallManager.isModuleUnlocked(CulturalModule.SPIRITUAL)
    var showPaywall by remember { mutableStateOf(false) }
    var selectedSiteForDetail by remember { mutableStateOf<SpiritualSite?>(null) }

    Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        // Header
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(containerColor = Color(0xFFE0F2F1)),
            shape = RoundedCornerShape(12.dp)
        ) {
            Row(
                modifier = Modifier.padding(16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    Icons.Default.Place,
                    contentDescription = null,
                    tint = Color(0xFF00796B),
                    modifier = Modifier.size(36.dp)
                )
                Spacer(modifier = Modifier.width(12.dp))
                Column {
                    Text("તીર્થ દર્શન અને યાત્રા મેપ", fontWeight = FontWeight.Bold, fontSize = 18.sp, color = Color(0xFF004D40))
                    Text("Sacred Heritage Sites & Audio Walking Tours", fontSize = 13.sp, color = Color(0xFF00796B))
                }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(repository.spiritualSites) { site ->
                val siteAccessible = site.isSampleFree || isUnlocked

                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable {
                            if (siteAccessible) {
                                selectedSiteForDetail = site
                            } else {
                                showPaywall = true
                            }
                        },
                    shape = RoundedCornerShape(12.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = if (siteAccessible) MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
                        else MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.25f)
                    )
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(site.name, fontWeight = FontWeight.Bold, fontSize = 18.sp)
                            if (!siteAccessible) {
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Icon(Icons.Default.Lock, contentDescription = "Locked", tint = Color.Gray, modifier = Modifier.size(16.dp))
                                    Spacer(modifier = Modifier.width(4.dp))
                                    Text("LOCKED", fontSize = 11.sp, color = Color.Gray)
                                }
                            }
                        }

                        Text("${site.location} · ${site.duration}", fontSize = 12.sp, color = MaterialTheme.colorScheme.primary)
                        Spacer(modifier = Modifier.height(6.dp))
                        Text(site.significance, fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)

                        Spacer(modifier = Modifier.height(10.dp))
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.End
                        ) {
                            FilledTonalButton(
                                onClick = {
                                    if (siteAccessible) selectedSiteForDetail = site
                                    else showPaywall = true
                                }
                            ) {
                                Icon(Icons.Default.VolumeUp, contentDescription = null, modifier = Modifier.size(16.dp))
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(if (siteAccessible) "Audio Guide" else "Unlock Guide")
                            }
                        }
                    }
                }
            }
        }
    }

    if (showPaywall) {
        PaywallBottomSheet(
            module = CulturalModule.SPIRITUAL,
            paywallManager = paywallManager,
            onDismiss = { showPaywall = false }
        )
    }

    selectedSiteForDetail?.let { site ->
        AlertDialog(
            onDismissRequest = { selectedSiteForDetail = null },
            title = { Text(site.name, fontWeight = FontWeight.Bold) },
            text = {
                Column {
                    Text(site.location, fontWeight = FontWeight.SemiBold, color = MaterialTheme.colorScheme.primary)
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(site.fullHistory, fontSize = 14.sp, lineHeight = 20.sp)
                    Spacer(modifier = Modifier.height(12.dp))
                    Text("મુખ્ય તથ્યો (Key Facts):", fontWeight = FontWeight.Bold, fontSize = 13.sp)
                    site.keyFacts.forEach { fact ->
                        Text("• $fact", fontSize = 12.sp, modifier = Modifier.padding(vertical = 2.dp))
                    }
                }
            },
            confirmButton = {
                Button(onClick = { selectedSiteForDetail = null }) { Text("Close") }
            }
        )
    }
}
