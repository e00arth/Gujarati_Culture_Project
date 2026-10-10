package com.gujarati.culture.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gujarati.culture.billing.PaywallManager
import com.gujarati.culture.models.CulturalModule

@Composable
fun PaywallBottomSheet(
    module: CulturalModule,
    paywallManager: PaywallManager,
    onDismiss: () -> Unit
) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    Icons.Default.Lock,
                    contentDescription = "Locked Feature",
                    tint = MaterialTheme.colorScheme.primary,
                    modifier = Modifier.size(28.dp)
                )
                Spacer(modifier = Modifier.width(10.dp))
                Text(
                    text = "Unlock ${module.titleEn}",
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold
                )
            }
        },
        text = {
            Column(modifier = Modifier.fillMaxWidth()) {
                Text(
                    text = "Get lifetime access to ${module.titleGu} with offline audio, full chapters, and interactive guides.",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )

                Spacer(modifier = Modifier.height(16.dp))

                // Feature Highlights
                val highlights = when (module) {
                    CulturalModule.FOLKLORE -> listOf(
                        "All Halarda (lullabies) & Rasdhar folk audio",
                        "High-definition oral story narrations",
                        "Offline audio playback mode"
                    )
                    CulturalModule.SPIRITUAL -> listOf(
                        "Full Somnath, Dwarka & Girnar audio tours",
                        "GPS interactive pilgrimage map & coordinates",
                        "Deep architectural history & sacred stories"
                    )
                    CulturalModule.LIBRARY -> listOf(
                        "All 7 Cultural Heritage E-Books",
                        "Offline native reader with Gujarati font scaler",
                        "Full access to modern and public domain anthologies"
                    )
                    CulturalModule.LIFESTYLE -> listOf(
                        "Complete Gujarati Ayurvedic diet guides",
                        "Patola & Bandhani textile masterclasses",
                        "Subterranean Stepwell (Vav) architectural archives"
                    )
                    else -> listOf("All module features included")
                }

                highlights.forEach { highlight ->
                    Row(
                        modifier = Modifier.padding(vertical = 4.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            Icons.Default.CheckCircle,
                            contentDescription = null,
                            tint = Color(0xFF4CAF50),
                            modifier = Modifier.size(18.dp)
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(highlight, style = MaterialTheme.typography.bodySmall)
                    }
                }

                Spacer(modifier = Modifier.height(20.dp))

                // Single Module Option
                OutlinedCard(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(12.dp),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Column {
                            Text(module.titleEn, fontWeight = FontWeight.SemiBold)
                            Text("Lifetime Single Module", style = MaterialTheme.typography.bodySmall, color = Color.Gray)
                        }
                        Button(onClick = {
                            paywallManager.unlockModule(module)
                            onDismiss()
                        }) {
                            Text(module.price)
                        }
                    }
                }

                Spacer(modifier = Modifier.height(10.dp))

                // All-Access Bundle Option (Best Value)
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer),
                    shape = RoundedCornerShape(12.dp)
                ) {
                    Column(modifier = Modifier.padding(12.dp)) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Icon(Icons.Default.Star, contentDescription = null, tint = Color(0xFFFFB300))
                                Spacer(modifier = Modifier.width(6.dp))
                                Text("All-Access Heritage Pass", fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.onPrimaryContainer)
                            }
                            Surface(
                                color = MaterialTheme.colorScheme.primary,
                                shape = RoundedCornerShape(8.dp)
                            ) {
                                Text("BEST VALUE", modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp), fontSize = 10.sp, color = Color.White, fontWeight = FontWeight.Bold)
                            }
                        }
                        Text("Unlocks all 5 modules across the entire app forever.", style = MaterialTheme.typography.bodySmall)
                        Spacer(modifier = Modifier.height(8.dp))
                        Button(
                            modifier = Modifier.fillMaxWidth(),
                            colors = ButtonDefaults.buttonColors(containerColor = MaterialTheme.colorScheme.primary),
                            onClick = {
                                paywallManager.unlockAllAccess()
                                onDismiss()
                            }
                        ) {
                            Text("Unlock All for ${CulturalModule.BUNDLE_PRICE}")
                        }
                    }
                }

                Spacer(modifier = Modifier.height(12.dp))

                // Developer/Testing Instant Unlock
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.Center
                ) {
                    TextButton(onClick = {
                        paywallManager.unlockModule(module)
                        onDismiss()
                    }) {
                        Text("⚡ [Test Mode] Instant Unlock for Testing", fontSize = 12.sp, color = MaterialTheme.colorScheme.tertiary)
                    }
                }
            }
        },
        confirmButton = {},
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Close")
            }
        }
    )
}
