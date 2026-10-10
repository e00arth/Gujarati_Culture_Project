package com.gujarati.culture.data

import android.content.Context
import android.content.SharedPreferences
import com.google.gson.Gson
import com.gujarati.culture.models.*
import java.io.InputStreamReader

class CultureRepository private constructor(context: Context) {
    private val appContext = context.applicationContext
    private val prefs: SharedPreferences = appContext.getSharedPreferences("culture_repo_prefs", Context.MODE_PRIVATE)

    var categories: List<CategoryItem> = emptyList()
        private set
    var allKehvto: List<KehvatItem> = emptyList()
        private set

    val favorites = mutableSetOf<String>()
    val masteredStudyIds = mutableSetOf<String>()

    init {
        loadFavorites()
        loadStudyProgress()
        loadKehvtoData()
    }

    private fun loadFavorites() {
        val favSet = prefs.getStringSet("favorite_ids", emptySet()) ?: emptySet()
        favorites.clear()
        favorites.addAll(favSet)
    }

    fun toggleFavorite(id: String): Boolean {
        val isFav = if (favorites.contains(id)) {
            favorites.remove(id)
            false
        } else {
            favorites.add(id)
            true
        }
        prefs.edit().putStringSet("favorite_ids", favorites.toSet()).apply()
        return isFav
    }

    fun isFavorite(id: String): Boolean = favorites.contains(id)

    private fun loadStudyProgress() {
        val mastered = prefs.getStringSet("mastered_ids", emptySet()) ?: emptySet()
        masteredStudyIds.clear()
        masteredStudyIds.addAll(mastered)
    }

    fun markStudyStatus(id: String, isMastered: Boolean) {
        if (isMastered) {
            masteredStudyIds.add(id)
        } else {
            masteredStudyIds.remove(id)
        }
        prefs.edit().putStringSet("mastered_ids", masteredStudyIds.toSet()).apply()
    }

    fun isMastered(id: String): Boolean = masteredStudyIds.contains(id)

    private fun loadKehvtoData() {
        try {
            appContext.assets.open("kehvto_full.json").use { stream ->
                val reader = InputStreamReader(stream)
                val payload = Gson().fromJson(reader, KehvtoAssetPayload::class.java)
                categories = payload.categories ?: emptyList()
                allKehvto = payload.kehvto ?: emptyList()
            }
        } catch (e: Exception) {
            e.printStackTrace()
            // Fallback sample if asset not found or parse error
            categories = listOf(
                CategoryItem("patience", mapOf("gu" to "ધીરજ", "en" to "Patience")),
                CategoryItem("unity", mapOf("gu" to "સંપ", "en" to "Unity"))
            )
            allKehvto = listOf(
                KehvatItem(
                    id = "gu-utavle-amba",
                    text = "ઉતાવળે આંબા ન પાકે",
                    roman = "Utavle aamba na paake",
                    categories = listOf("patience"),
                    literal = mapOf("en" to "Mangoes do not ripen in haste"),
                    meaning = mapOf(
                        "gu" to mapOf("simple" to "ધીરજ રાખવાથી સારું ફળ મળે છે."),
                        "en" to mapOf("simple" to "Patience yields sweet results.")
                    ),
                    story = mapOf("en" to "A farmer watered a mango tree daily but could not force it to ripen ahead of its season.")
                )
            )
        }
    }

    fun filter(
        query: String = "",
        categoryId: String? = null,
        favoritesOnly: Boolean = false
    ): List<KehvatItem> {
        val cleanQuery = query.trim().lowercase()
        return allKehvto.filter { item ->
            val matchesCategory = categoryId == null || item.categories.contains(categoryId)
            val matchesFavorite = !favoritesOnly || favorites.contains(item.id)
            val matchesQuery = cleanQuery.isEmpty() ||
                    item.text.lowercase().contains(cleanQuery) ||
                    item.roman.lowercase().contains(cleanQuery) ||
                    (item.literal?.values?.any { it.lowercase().contains(cleanQuery) } == true) ||
                    (item.meaning?.values?.any { langMap -> langMap.values.any { it.lowercase().contains(cleanQuery) } } == true)

            matchesCategory && matchesFavorite && matchesQuery
        }
    }

    // Cultural Content for Modules 2 to 5
    val folkloreTracks: List<FolkloreTrack> by lazy {
        listOf(
            FolkloreTrack(
                id = "fl-1",
                title = "શિવાજીનું હાલરડું (Shivaji Nu Halardu)",
                category = "Halarda (Lullaby)",
                duration = "4:35 mins",
                description = "રાષ્ટ્રીય શાયર ઝવેરચંદ મેઘાણી રચિત વીરરસનું અજર-અમર હાલરડું. જીજાબાઈ બાળ શિવાજીને પાળણામાં ઝુલાવતા વીરતાના પાઠ પઢાવે છે.",
                lyricsOrText = "આભમાં ઊગેલ ચાંદલો ને જીજાબાઈને આવ્યા બાળ...\nપોઢે પાળણે બાળ શિવાજી, જાગે વીરતા અપાર.\nખડગની ધારે સૂતો મારો વીરલો, સિંહણ કેરો જાયો...",
                isSampleFree = true
            ),
            FolkloreTrack(
                id = "fl-2",
                title = "ચંદનનું પારણું (Chandan Nu Parnu)",
                category = "Halarda (Lullaby)",
                duration = "3:20 mins",
                description = "સૌરાષ્ટ્રનું પરંપરાગત મીઠું હાલરડું, જેમાં માતૃત્વ અને વાત્સલ્યનો મધુર સૂર વહે છે.",
                lyricsOrText = "ચંદનનું પારણું ને રેશમની દોરી,\nસૂઈ જા રે મારા લાડકવાયા, નિંદરા રાણી આવી...",
                isSampleFree = true
            ),
            FolkloreTrack(
                id = "fl-3",
                title = "સૌરાષ્ટ્રની રસધાર: સિંહનું દાન (Sinh Nu Dan)",
                category = "Rasdhar Folk Tale",
                duration = "8:15 mins",
                description = "ગીરના જંગલો અને કાઠિયાવાડના બહાદુર બહારવટિયાઓની અનોખી લોકવાર્તા.",
                lyricsOrText = "સૌરાષ્ટ્રની ધરતી સંત અને શૂરાઓની છે. જેસલ-તોરલ અને લાખા ફૂલાણીના ઈતિહાસની અસ્મિતા...",
                isSampleFree = false
            ),
            FolkloreTrack(
                id = "fl-4",
                title = "હાલા કરું વ્હાલા કરું (Hala Karu Vhala Karu)",
                category = "Halarda (Lullaby)",
                duration = "3:50 mins",
                description = "માતાના સ્નેહનું અમૃત સમાન પરંપરાગત હાલરડું.",
                lyricsOrText = "હાલા કરું વ્હાલા કરું, આંખલડીના તારા કરું...",
                isSampleFree = false
            )
        )
    }

    val spiritualSites: List<SpiritualSite> by lazy {
        listOf(
            SpiritualSite(
                id = "sp-somnath",
                name = "Somnath Temple (પ્રભાસ પાટણ)",
                location = "Prabhas Patan, Gir Somnath",
                duration = "Audio Tour: 18 mins",
                significance = "The First of the Twelve Holy Jyotirlingas of Lord Shiva. Symbol of Civilizational Resilience.",
                fullHistory = "The Somnath temple has withstood numerous invasions and reconstructions throughout history. Completed in 1951 through the vision of Sardar Vallabhbhai Patel and K.M. Munshi, it stands as the 'Eternal Shrine'.",
                keyFacts = listOf(
                    "Baan-Stambh (Arrow Pillar): Direct water route to South Pole with zero landmass.",
                    "Triveni Sangam: Sacred confluence of Hiran, Kapila, and Saraswati rivers.",
                    "Bhalka Tirth: The sacred spot nearby where Lord Krishna departed for heavenly abode."
                ),
                isSampleFree = true
            ),
            SpiritualSite(
                id = "sp-dwarka",
                name = "Dwarkadhish Temple (જગત મંદિર)",
                location = "Dwarka, Devbhumi Dwarka",
                duration = "Audio Tour: 22 mins",
                significance = "The Kingdom of Lord Krishna. One of the Char Dham pilgrimage sites.",
                fullHistory = "Dwarka ('Door to Liberation') was the sovereign kingdom of Lord Krishna. The 5-storied temple built in Māru-Gurjara style towers majestically over the Arabian Sea.",
                keyFacts = listOf(
                    "Submerged Ancient City discovered off the coast by marine archaeologists.",
                    "Dhvajaji Ceremony: Holy 52-yard flag changed 5 times daily.",
                    "98th Divya Desam glorified by ancient Vaishnava Alvars."
                ),
                isSampleFree = false
            ),
            SpiritualSite(
                id = "sp-girnar",
                name = "Girnar Maha Tirth (જૂનાગઢ)",
                location = "Junagadh",
                duration = "Audio Tour: 25 mins",
                significance = "Sacred mountain for Jainism (Lord Neminath) and Hinduism (Lord Dattatreya). 9,999 steps.",
                fullHistory = "Older than the Himalayas, Girnar has been a sanctuary for ascetics and seekers for millennia.",
                keyFacts = listOf(
                    "Lord Neminath, the 22nd Jain Tirthankara, attained Moksha here.",
                    "Guru Dattatreya's holy padukas situated on the highest peak.",
                    "Bhavnath Fair held annually during Mahashivratri."
                ),
                isSampleFree = false
            )
        )
    }

    val libraryBooks: List<EBookBook> by lazy {
        listOf(
            EBookBook(
                id = "bk-1",
                titleGu = "ગુજરાતી કહેવતો અને લોકવિદ્યા",
                titleEn = "Book 1: Gujarati Kehavato & Folklore Origins",
                author = "Cultural Heritage Series",
                summary = "1,400+ traditional proverbs, multi-tier philosophical meanings, and historical folklore fables.",
                sampleChapterTitle = "પ્રકરણ ૧: ધીરજ અને પુરુષાર્થ",
                sampleChapterContent = "ધીરજ એ માનવ જીવનનું સૌથી મોટું ઘરેણું છે. 'ઉતાવળે આંબા ન પાકે' કહેવત દ્વારા આપણા પૂર્વજોએ સમજાવ્યું છે કે પ્રકૃતિ પોતાની ગતિએ ચાલે છે...",
                fullChaptersCount = 20,
                isSampleFree = true
            ),
            EBookBook(
                id = "bk-2",
                titleGu = "લોકસાહિત્યની સુવાસ",
                titleEn = "Book 2: Fragrance of Lok Sahitya",
                author = "Jhaverchand Meghani & Oral Traditions",
                summary = "Anthology of oral folklore, Halarda lullabies, Dayro couplets, and Saurashtra legends.",
                sampleChapterTitle = "હાલરડાં: માતૃત્વનો અમૃત કુંભ",
                sampleChapterContent = "હાલરડું એ માત્ર બાળકને ઊંઘાડવાનું ગીત નથી, પણ તેનામાં સંસ્કાર અને શૂરવીરતાનું સિંચન કરવાનો મંત્ર છે...",
                fullChaptersCount = 15,
                isSampleFree = false
            ),
            EBookBook(
                id = "bk-3",
                titleGu = "ગુજરાતનો આધ્યાત્મિક વારસો",
                titleEn = "Book 3: Spiritual Heritage of Gujarat",
                author = "Spiritual Heritage Research",
                summary = "Chronicles of Somnath, Dwarka, Palitana, Girnar, and the lives of Narsinh Mehta and Shrimad Rajchandra.",
                sampleChapterTitle = "સોમનાથ: ચિરંજીવી શ્રદ્ધાનું પ્રતીક",
                sampleChapterContent = "સોમનાથ જ્યોતિર્લિંગનો ઈતિહાસ એટલે ભારતીય સંસ્કૃતિની અતૂટ શ્રદ્ધાની ગાથા...",
                fullChaptersCount = 18,
                isSampleFree = false
            ),
            EBookBook(
                id = "bk-4",
                titleGu = "આધુનિક ગુજરાતના ઘડવૈયાઓ",
                titleEn = "Book 4: Makers of Modern Gujarat",
                author = "Biographical Profiles",
                summary = "Inspiring biographies of Gandhi, Sardar Patel, Vikram Sarabhai, and industrial pioneers.",
                sampleChapterTitle = "સરદાર પટેલ: લોખંડી સંકલ્પ",
                sampleChapterContent = "સરદાર વલ્લભભાઈ પટેલે ૫૬૫ રજવાડાંઓનું એકીકરણ કરીને અખંડ ભારતના નિર્માણનો ચમત્કાર કર્યો...",
                fullChaptersCount = 25,
                isSampleFree = false
            )
        )
    }

    val lifestyleArticles: List<LifestyleArticle> by lazy {
        listOf(
            LifestyleArticle(
                id = "ls-thali",
                category = "Culinary & Ayurveda",
                title = "The Gujarati Thali: Ayurvedic Alchemy",
                subtitle = "The science behind Shad Rasa (6 tastes) and balanced digestion",
                content = "A traditional Gujarati Thali is crafted according to ancient Ayurvedic principles, incorporating sweet, salty, sour, pungent, bitter, and astringent notes in every meal.",
                bulletPoints = listOf(
                    "Jaggery and sugar balance high salinity in coastal soil and aid carbohydrate assimilation.",
                    "Farsan (Dhokla, Khandvi) evolved from merchant travel traditions requiring shelf-stable nutrition.",
                    "Chaas (Spiced Buttermilk) cools the digestive fire and supplies gut-friendly probiotics."
                )
            ),
            LifestyleArticle(
                id = "ls-textiles",
                category = "Art & Textiles",
                title = "Patan Patola & Bandhani: Geometric Precision",
                subtitle = "Double ikat silk weaving taking up to a year per saree",
                content = "Patan Patola represents double ikat silk weaving where warp and weft are individually tie-dyed before weaving. Famous proverb: 'Padi patole bhat, fatey pan fitey nahin'.",
                bulletPoints = listOf(
                    "Natural dyes extracted from pomegranate rinds, turmeric, and indigo.",
                    "Identical pattern on front and reverse side.",
                    "Protected under Geographical Indication (GI) tag."
                )
            ),
            LifestyleArticle(
                id = "ls-vav",
                category = "Architecture",
                title = "Stepwells (Vavs) of Gujarat: Subterranean Palaces",
                subtitle = "Rani ki Vav (UNESCO World Heritage) & Adalaj Vav",
                content = "In arid climates, stepwells were not just water reservoirs but cultural sanctuaries, cooling resting spots for caravans, and magnificent works of subterranean stone sculpture.",
                bulletPoints = listOf(
                    "Rani ki Vav in Patan features over 500 principal sculptures dedicated to Lord Vishnu.",
                    "Multi-storey pavilions designed with intricate Māru-Gurjara pillars and ventilation.",
                    "Micro-climate inside the stepwell remains 5 to 6 degrees cooler than surface heat."
                )
            )
        )
    }

    companion object {
        @Volatile
        private var instance: CultureRepository? = null

        fun getInstance(context: Context): CultureRepository {
            return instance ?: synchronized(this) {
                instance ?: CultureRepository(context.applicationContext).also { instance = it }
            }
        }
    }
}
