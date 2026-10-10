package com.gujarati.culture.models

enum class AppLanguage(val code: String, val label: String) {
    GUJARATI("gu", "ગુજરાતી"),
    HINDI("hi", "हिन्दी"),
    ENGLISH("en", "English")
}

enum class MeaningLevel {
    SIMPLE,
    NORMAL,
    ADVANCED
}

enum class DetailSection(val level: MeaningLevel? = null) {
    BACKSTORY(null),
    SIMPLE(MeaningLevel.SIMPLE),
    NORMAL(MeaningLevel.NORMAL),
    ADVANCED(MeaningLevel.ADVANCED),
    STORY(null)
}

data class CategoryItem(
    val id: String,
    val name: Map<String, String>
) {
    fun getDisplayName(lang: AppLanguage): String {
        return name[lang.code] ?: name["en"] ?: name["gu"] ?: id
    }
}

data class KehvatItem(
    val id: String,
    val lang: String = "gu",
    val text: String,
    val roman: String = "",
    val categories: List<String> = emptyList(),
    val literal: Map<String, String>? = null,
    val backstory: Map<String, String>? = null,
    val meaning: Map<String, Map<String, String>>? = null,
    val story: Map<String, String>? = null,
    val hindi: String? = null,
    val folk: Boolean = false
) {
    fun getLiteral(lang: AppLanguage): String? {
        return literal?.get(lang.code) ?: literal?.get("en")
    }

    fun getBackstory(lang: AppLanguage): String? {
        return backstory?.get(lang.code) ?: backstory?.get("en") ?: backstory?.get("gu")
    }

    fun getStory(lang: AppLanguage): String? {
        return story?.get(lang.code) ?: story?.get("en") ?: story?.get("gu")
    }

    fun getMeaning(lang: AppLanguage, level: MeaningLevel): String? {
        val levelKey = when (level) {
            MeaningLevel.SIMPLE -> "simple"
            MeaningLevel.NORMAL -> "normal"
            MeaningLevel.ADVANCED -> "advanced"
        }
        val langMap = meaning?.get(lang.code) ?: meaning?.get("en") ?: meaning?.get("gu")
        return langMap?.get(levelKey)
    }

    fun hasMeaning(): Boolean = !meaning.isNullOrEmpty()
}

data class KehvtoAssetPayload(
    val categories: List<CategoryItem>,
    val kehvto: List<KehvatItem>
)

enum class CulturalModule(
    val id: String,
    val titleGu: String,
    val titleEn: String,
    val price: String,
    val isFree: Boolean = false
) {
    PROVERBS("module_proverbs", "કહેવતો (Proverbs)", "Proverbs & Wisdom", "Free", true),
    FOLKLORE("module_folklore_audio", "લોકસાહિત્ય (Folklore Audio)", "Folklore & Halarda Audio", "$2.99 / ₹199", false),
    SPIRITUAL("module_spiritual_map", "તીર્થ દર્શન (Spiritual Map)", "Spiritual Heritage & Audio Map", "$2.99 / ₹199", false),
    LIBRARY("module_digital_library", "અસ્મિતા ગ્રંથાલય (Digital Library)", "Digital Library & E-Reader", "$3.99 / ₹299", false),
    LIFESTYLE("module_culture_lifestyle", "સંસ્કૃતિ (Culture & Lifestyle)", "Culture & Lifestyle Compendium", "$2.99 / ₹199", false);

    companion object {
        const val BUNDLE_ALL_ACCESS = "bundle_all_access"
        const val BUNDLE_PRICE = "$7.99 / ₹599"
    }
}

data class FolkloreTrack(
    val id: String,
    val title: String,
    val category: String,
    val duration: String,
    val description: String,
    val audioUrl: String = "",
    val lyricsOrText: String,
    val isSampleFree: Boolean = false
)

data class SpiritualSite(
    val id: String,
    val name: String,
    val location: String,
    val duration: String,
    val significance: String,
    val fullHistory: String,
    val keyFacts: List<String>,
    val isSampleFree: Boolean = false
)

data class EBookBook(
    val id: String,
    val titleGu: String,
    val titleEn: String,
    val author: String,
    val summary: String,
    val sampleChapterTitle: String,
    val sampleChapterContent: String,
    val fullChaptersCount: Int,
    val isSampleFree: Boolean = false
)

data class LifestyleArticle(
    val id: String,
    val category: String,
    val title: String,
    val subtitle: String,
    val content: String,
    val bulletPoints: List<String>
)
